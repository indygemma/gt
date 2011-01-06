require "actor"

Toy = class(Actor)

local IDLE = 0
local BEING_PLAYED = 1

function Toy:__init(world, name)
    Actor.__init(self, world)
    self.name = name
end

function Toy:update()
    while 1 do
        print("Toy update", self.name, "@", os.clock())
        coroutine.yield({ sleep=1 })
    end
end
