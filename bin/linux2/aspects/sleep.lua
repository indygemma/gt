require "aspects/base"

-- The Sleepable Aspect knows how to handle actors that want
-- to sleep for a couple seconds (or milliseconds)
Sleepable = class(Aspect)
Sleepable.TYPE = "Sleepable"

function Sleepable:__init()
    Aspect.__init(self)
end
