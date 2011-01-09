require "aspects/base"

-- A MapItem is an aspect used by a Map2D aspect,
-- where an Actor using this item will be shown
-- on the map
MapItem = class(Aspect)
MapItem.TYPE = "MapItem"

function MapItem:__init( data )
    Aspect.__init(self)
    assert( data.id or data.f )
    -- the id mapping the actor to a map tile
    self.id = data.id
    -- f: determine whether this MapItem should trigger or not.
    -- for example:
    --
    --   function(i) return i > 10 end
    --
    self.f  = data.f
    self.map = nil -- reference to our map instance
end

-- A Map2D knows how to draw a map using MapItems
Map2D = class(Aspect)
Map2D.TYPE = "Map2D"

function Map2D:__init(data)
    assert(data.grid)
    Aspect.__init(self)
    self.origin = data.origin or { x=0, y=0 }
    self.grid   = data.grid
    self.sizes  = data.sizes or { x=1, y=1 }
    self.empty_floor_coords = self:collect_floor_coords(self.grid)
end

function Map2D:collect_floor_coords( grid )
    -- collect the coordinates for empty floors
    -- to spawn things randomly later on
    local w = table.getn(grid[1])
    local h = table.getn(grid)
    local result = {}
    for y=1,h do
        for x=1,w do
            local realX = self:realX( x )
            local realY = self:realY( y )
            local tile = grid[y][x]
            if tile == 0 then
                table.insert(result, {x=realX,y=realY})
            end
        end
    end
    return result
end

function Map2D:postSetup()
    -- execute this only after every other aspect instances are created
    print("setting up map2d instance")
    self:create_map()
end

function Map2D:realX( x )
    return self.origin.x + self.sizes.x/2 + self.sizes.x * (x-1)
end

function Map2D:realY( y )
    return self.origin.x + self.sizes.y/2 + self.sizes.y * (y-1)
end

function Map2D:mapX( x )
    return math.floor((x-self.origin.x)/self.sizes.x) + 1
end

function Map2D:mapY( y )
    return math.floor((y-self.origin.y)/self.sizes.y) + 1
end

local function createActor( map2d, actor_class, x, y )
    local callbacks = {}
    -- on creation of the position aspect, execute the following
    callbacks[Position.TYPE] = function(aspect) aspect:set(x,y) end
    callbacks[MapItem.TYPE]  = function(aspect) aspect.map = map2d end
    return ACTOR_MANAGER:create(
        actor_class,
        callbacks
    )
end

function Map2D:create_map()
    local w = table.getn(self.grid[1])
    local h = table.getn(self.grid)

    -- mapping of tile Nr => actor. for example 1 => Wall
    local actor_class_mapping, map_item_funcs = self.createActorMapping()

    print("w:", w, "h:", h)
    for y=1,h do
        for x=1,w do
            local realX = self:realX( x )
            local realY = self:realY( y )
            local tile = self.grid[y][x]
            local actor_class = actor_class_mapping[tile]
            if actor_class then
                createActor( self, actor_class, realX, realY )
            end
            -- check whether there are any functions pending
            for f,actor_class in pairs(map_item_funcs) do
                if f(tile) then
                    createActor( self, actor_class, realX, realY )
                end
            end
        end
    end
end

function Map2D:createActorMapping()
    local mapitems       = ASPECT_MANAGER:getActorsWithAspectClass(MapItem)
    local mapping_result = {}
    local func_result    = {}
    for actor_class,mapitem_args in pairs(mapitems) do
        if mapitem_args.args.f ~= nil and type(mapitem_args.args.f) == "function" then
            func_result[mapitem_args.args.f] = actor_class
        else
            mapping_result[mapitem_args.args.id] = actor_class
        end
    end
    return mapping_result, func_result
end

-- The RandomMapSpawn aspect knows how to randomly spawn
-- another actor instance on the map
RandomMapSpawn = class(Aspect)
RandomMapSpawn.TYPE = "RandomMapSpawn"

function RandomMapSpawn:__init(data)
    assert(data.candidate_tiles ~= nil)
    assert(data.activate ~= nil)
    assert(type(data.activate) == "table")
    assert(data.actor_class ~= nil)
    Aspect.__init(self)
    self.candidate_tiles = data.candidate_tiles
    self.activate_class  = data.activate[1]
    self.activate_key    = data.activate[2]
    self.actor_class     = data.actor_class
end

function RandomMapSpawn:spawnOnRandomEmptyFloor( actor_class )
    -- lays down an instance of actor_class on available Map2D
    -- instances. If there are more than one, then all of them
    -- will be placed.
    local map_aspects = ASPECT_MANAGER:getAspect( Map2D )
    local count = 0
    for i,aspect in ipairs(map_aspects) do
        count = count + 1
        local coords = utils.random_entry( aspect.empty_floor_coords )
        createActor( aspect, actor_class, coords.x, coords.y )
    end
end

function RandomMapSpawn:update()
    -- assumes only one Mouse/Keyboard-Input aspect running
    local input = self:getActor():getAspect(self.activate_class)
    local passed = input:getStatus( self.activate_key )
    if passed then
        self:spawnOnRandomEmptyFloor( self.actor_class )
    end
end

-- The LevelSpawn aspect knows how to randomly spawn another map
LevelSpawn = class(Aspect)
LevelSpawn.TYPE = "LevelSpawn"

function LevelSpawn:__init(data)
    assert(data.activate ~= nil)
    assert(type(data.activate) == "table")
    assert(data.actor_class ~= nil)
    Aspect.__init(self)
    self.activate_class  = data.activate[1]
    self.activate_key    = data.activate[2]
    self.actor_class     = data.actor_class
end

function LevelSpawn:update()
    -- assumes only one Mouse/Keyboard-Input aspect running
    local input = self:getActor():getAspect(self.activate_class)
    local passed = input:getStatus( self.activate_key )
    if passed then
        ACTOR_MANAGER:create( self.actor_class )
    end
end
