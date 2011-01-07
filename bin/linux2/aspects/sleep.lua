require "aspects/base"

-- The Sleepable Aspect knows how to handle actors that want
-- to sleep for a couple seconds (or milliseconds)
Sleepable = class(Aspect)
Sleepable.TYPE = "Sleepable"

function Sleepable:__init(data)
    Aspect.__init(self)
    self:wakeUp()
end

function Sleepable:sleep( seconds )
    self.sleeping    = true
    self.sleep_start = os.clock()
    self.sleep_stop  = self.sleep_start + seconds
end

function Sleepable:wakeUp()
    self.sleeping    = false
    self.sleep_start = nil
    self.sleep_stop  = nil
end

function Sleepable:isAwake()
    return not self.sleeping
end

function Sleepable:update()
    if self.sleep_stop ~= nil then
        if (os.clock() >= self.sleep_stop) then
            print("WAKING UP", os.clock(), self:getActor().uuid, self.sleeping, self.sleep_start, self.sleep_stop)
            self:wakeUp()
        end
    end
end
