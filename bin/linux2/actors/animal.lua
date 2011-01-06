require "actor"
utils = require "utils"

Animal = class(Actor)

local SEEKING_TOY  = 0
local PLAYING_TOY  = 1
local SEEKING_FOOD = 2
local EATING_FOOD  = 3

function Animal:__init(world, name)
    Actor.__init(self, world)
    self.name                  = name
    self.hunger_level          = 0
    self.critical_hunger_level = math.random() * 100
    self:seek_toy()
end

function Animal:print_pos()
    if self.node then
        local x,y = self.node:getPosition()
        print("POS ", x, " ", y)
    end
end

function Animal:seek_toy()
    --target onto a toy in the field
    --TODO: implement targeting logic
    self.state = SEEKING_TOY
    if not self.node then return end
    print(string.format("seeking toy, there are %d other animals and %d toys", table.getn(self.world.ANIMALS), table.getn(self.world.TOYS)))
    local count = table.getn(self.world.TOYS)
    if count > 0 then
        self.target = utils.random_entry(self.world.TOYS)
        test = self.world.TEST[1]
        print(" self (address) ", self)
        print( "TEST address", test )
        print("chosen target:", self.target.name)
        print("self.target", self.target)
        print("self.target.node pointer", self.target.node, self.target.node._pointer)
        table.foreach( self.world.TOYS, function(k,v) print("toy pointers", v, v.node,v.node._pointer,v.node.mt) end )
        print("1asds", self.target.node)
        --self.target.node:setScale(1,1,1)
        --table.foreach(self.target.node, print)
        print( "self.target.node.getPosition", self.target.node.getPosition )
        x,y,z = self.target.node:getPosition()
        print("positions:", x,y,z)
        local x,y = self.target:get_pos()
        print("HUH")
        print("target position:", x, ":", y)
    end
end

function Animal:update_hunger(n)
    -- every second the hunger_level decreases by n units.
    self.hunger_level = self.hunger_level - n
end

function Animal:hungry()
    -- returns true if the animal gets hungry
    return self.hunger_level >= self.critical_hunger_level
end

function Animal:find_path(target)
    -- TODO: might be better in parent class
    return {}
end

function Animal:move_along_path(target)
    -- TODO: might be better in parent class
end

function Animal:collide_with_entity(target)
    -- TODO: might be better upclass
    return true
end

function Animal:check_if_toy_exists(target)
    -- TODO: might be better upclass
    return true
end

function Animal:play_with_toy(target)

end

function Animal:eat_food(target)
    self.hunger_level = 0
end

function Animal:update()
    local snapshot = os.clock()
    while 1 do
        self:update_hunger(2)
        if self.state == EATING_FOOD then
            -- stay in this state for five seconds, then
            -- retarget to a random toy in the field
            coroutine.yield({ sleep=5 })
            self:seek_toy()
        elseif self.state == SEEKING_TOY then
            if not self.target then
                self:seek_toy()
                coroutine.yield({ sleep=0.15 })
            end
            -- we're locked on to a toy
            -- check whether we're hungry enough to seek food
            if self:hungry() then
                self:seek_food()
                coroutine.yield()
            end
            -- calculate A* path to the toy and move along that path
            local path = self:find_path(self.target)
            self:move_along_path(path)
            if self:collide_with_entity(self.target) then
                self:play_with_toy(self.target)
                coroutine.yield()
            else
                -- update every 50ms
                coroutine.yield({ sleep=0.05 })
            end
        elseif self.state == PLAYING_TOY then
            -- we're currently playing with a toy.
            -- stay in this state until the target toy dissapears,
            -- after which a new toy is targeted
            if not self:check_if_toy_exists(self.target) then
                self:seek_toy()
                coroutine.yield()
            end
            -- or we get hungry, then seek food
            if self:hungry() then
                self:seek_food()
                coroutine.yield()
            end
            coroutine.yield({ sleep=0.5 })
        elseif self.state == SEEKING_FOOD then
            -- calculate A* path to the food and move along that path
            local path = self:find_path(self.target)
            self:move_along_path(path)
            if self:collide_with_entity(self.target) then
                self:eat_food(self.target)
                coroutine.yield()
            else
                coroutine.yield({ sleep=0.05 })
            end
        end
        print(self.name, "animal updating", "@", os.clock())
        coroutine.yield({ sleep=0.1 })
    end
end
