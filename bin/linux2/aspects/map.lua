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
end

-- A Map2D knows how to draw a map using MapItems
Map2D = class(Aspect)
Map2D.TYPE = "Map2D"

function Map2D:__init(data)
    assert(data.grid)
    Aspect.__init(self)
    self.origin = data.origin or { 0, 0 }
    self.grid   = data.grid
    self.empty_floor_coords = self:collect_floor_coords( self.grid)
end

function Map2D:collect_floor_coords( grid )
    -- collect the coordinates for empty floors
    -- to spawn things randomly later on
    local w = table.getn(grid[1])
    local h = table.getn(grid)
    local result = {}
    for y=1,h do
        for x=1,w do
            local tile = grid[y][x]
            if tile == 0 then
                table.insert(result, {x=x,y=y})
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

local function createActor( actor_class, x, y )
    local callbacks = {}
    -- on creation of the position aspect, execute the following
    callbacks[Position.TYPE] = function(aspect) aspect:set(x,y) end
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
            local tile = self.grid[y][x]
            local actor_class = actor_class_mapping[tile]
            if actor_class then
                createActor( actor_class, x, y )
            end
            -- check whether there are any functions pending
            for f,actor_class in pairs(map_item_funcs) do
                if f(tile) then
                    createActor( actor_class, x, y )
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
    assert(data.actor_class ~= nil)
    Aspect.__init(self)
    self.candidate_tiles = data.candidate_tiles
    self.activate_type   = data.activate
    self.actor_class     = data.actor_class
end

local function random_entry( coords )
    -- returns a random element from a list of things
    local count = table.getn(coords)
    if count > 0 then
        local idx   = math.random( count )
        print("random_entry idx:", idx, " count:", count)
        local entry = coords[idx]
        if entry.node then
            print( "PENGUIN POINTER (random_entry)", entry.node, entry.node._pointer )
        end
        return entry
    end
    return nil
end

function RandomMapSpawn:spawnOnRandomEmptyFloor( actor_class )
    local map_aspects = ASPECT_MANAGER:getAspect( Map2D )
    local count = 0
    print("THERE ARE ", table.getn(map_aspects), " map_aspects")
    for i,aspect in ipairs(map_aspects) do
        count = count + 1
        local coords = random_entry( aspect.empty_floor_coords )
        print("SPAWN COUNT ", count, " @",coords.x,coords.y)
        createActor( actor_class, coords.x, coords.y )
    end
end

function RandomMapSpawn:update()
    -- assumes only one MouseInput aspect running
    local mouse_input = self:getActor():getAspect(MouseInput)
    local clicked = mouse_input:getClickStatus( self.activate_type )
    if clicked then
        print("")
        print("--- MOUSE CLICKED, spawning stuff ---")
        print("ACTIVATION: ", self.activate_type)
        --local actor_class = ASPECT_MANAGER:getActorClass( self:getActor().name )
        self:spawnOnRandomEmptyFloor( self.actor_class )
    end
end