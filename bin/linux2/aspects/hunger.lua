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
