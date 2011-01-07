ai = require "aspects/ai/base"

ai.Idle = class(SleepableAI)
ai.Idle.TYPE = "ai.Idle"

function ai.Idle:__init(data)
    SleepableAI.__init(self, data)
end

function ai.Idle:update()
    SleepableAI.update(self)
    --print("ai.Idle Update", self:getActor().uuid)
    if self.active then
        -- do the idle logic
        --print("ai.Idle is active", self:getActor().uuid)
        SleepableAI.sleep(self)
    end
end
