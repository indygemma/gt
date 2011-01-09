require "utils"
require "aspects/base"

-- Actors using this aspect are targetable by other actors
-- using the Targeting aspect
Target = class(Aspect)
Target.TYPE = "Target"

function Target:__init( data )
    Aspect.__init(self)
    assert( data.name ~= nil ) -- always required
    self.name = data.name
    self.is_targeted = false
    self.map = nil
end

function Target:targeted()
    return self.is_targeted
end

function Target:distanceScore()
    -- TODO: implement this
    return 100
end

-- Targeting aspect implements the actual targeting logic
Targeting = class(Aspect)
Targeting.TYPE = "Targeting"

function Targeting:__init( data )
    Aspect.__init(self)
    assert( data.targets )
    assert(table.getn(data.targets) > 0)
    self.target_types    = data.targets
    self.target          = data.current or nil
    self.target_instance = nil
end

function Targeting:postSetup()
    self:findTarget()
    self.line_object = game.app.add_line( self:getActor().uuid .. "_line" )
end

function Targeting:findTarget()
    if self.target then
        self:setTarget( self.target )
    else
        -- randomly pick one of the valid types if no default
        -- one is supplied
        self:setTarget( utils.random_entry( self.target_types ) )
    end
end

function Targeting:distanceScore()
    local x,y,z = self.target_instance:getAspect(Position):getPos()
    local px,py,pz = self:getActor():getAspect(Position):getPos()
    x = math.floor(x)
    y = math.floor(y)
    z = math.floor(z)
    px = math.floor(px)
    py = math.floor(py)
    pz = math.floor(pz)
    local diffsum = math.abs((x-px)+(y-py)+(z-pz))
    local score = math.sqrt( diffsum )
    print ("DISTANCE SCORE", score )
    return score
end

function Targeting:getPos()
    assert( self.target_instance )
    return self.target_instance:getAspect(Visual).scene_node:getPosition()
end

function Targeting:setTarget( targetname )
    local target_instances = ASPECT_MANAGER:getAspect( Target )
    if target_instances then
        -- target only those that are named 'targetname'
        local real_targets = {}
        for i,target in ipairs( target_instances ) do
            if target.name == targetname then
                local x,y,z = target:getActor():getAspect(Position):getPos()
                table.insert( real_targets, target )
            end
        end
        if table.getn( real_targets) > 0 then
            self.target_instance = utils.random_entry( real_targets ):getActor()
            self.target = targetname
            local x,y,z = self:getPos()
        end
    end
end

function Targeting:getNextNodePath()
    local n = table.getn( self.path )
    if n > 1 then
        return self.map:realX(self.path[2].x), self.map:realY(self.path[2].y)
    end
    return nil,nil
end

function Targeting:drawPath( path )
    -- path is a list of {x,y} tables that have to be transformed
    -- to the real coordinates first before drawing
    self.line_object:clear()
    self.line_object:begin(self:getActor().uuid.."_line")
    for i,node in ipairs( path ) do
        if i > 1 then
            local x = self.map:realX( node.x )
            local y = self.map:realY( node.y )
            self.line_object:position( x, 0, y )
        end
    end
    self.line_object:finish()
end

function Targeting:updatePath()
    -- calculate the path to our target using A* search
    self.map = self:getActor():getAspect( MapItem ).map
    -- 0. get our coordinates
    local x0,y0,_ = self:getActor():getAspect(Position):getPos()
    -- 1. get the target's coordinates
    local x1,_,y1 = self:getPos()
    -- 1.5 approximate the coords for the grid
    print( "raw coords", x0,y0,x1,y1 )
    x0 = self.map:mapX(x0)
    y0 = self.map:mapY(y0)
    x1 = self.map:mapX(x1)
    y1 = self.map:mapY(y1)
    -- 2. calculate path (list of coords) from current position
    --    to target
    print( "finding path", x0,y0,x1,y1)
    local path = A.findpath(
        -- pass the grid from the Map2D instance associated with
        -- the MapItem by our Actor
        self:getActor():getAspect(MapItem).map.grid,
        x0,y0,
        x1,y1
    )
    --A.printnodes(path)
    -- 2.5 draw the path from actor to target
    self:drawPath( path )
    -- 3. move to the direction of the first coords in that list
    self.path = path
end

function Targeting:currentTarget()
    return self.target
end

function Targeting:update()
    -- make sure we have a target locked on. If not, try until we do.
    if not self.target_instance then
        self:findTarget()
    end
end
