require "aspects/base"

Hunger = class(Aspect)
Hunger.TYPE = "Hunger"

function Hunger:__init(data)
    Aspect.__init(self)
    assert( data.level )
    assert( data.increase_rate )
    assert( data.critical )
    self.hunger_level         = data.level
    self.hunger_increase_rate = data.increase_rate
    self.hunger_critical      = data.critical
end

function Hunger:isCritical()
    return self.hunger_critical <= self.hunger_level
end

function Hunger:decrease( amount )
    self.hunger_level = self.hunger_level - amount
    if self.hunger_level < 0 then
        self.hunger_level = 0
    end
end

function Hunger:level()
    return self.hunger_level
end

function Hunger:update()
    print("increasing hunger level", self.hunger_level, os.clock(), self:getActor().uuid)
    self.hunger_level = self.hunger_level + self.hunger_increase_rate
end
