require "actor"

Food = class(Actor)

local IDLE   = 0
local MOVING = 1

function Food:__init(world, name)
    Actor.__init(self, world)
end
