ai = require "aspects/ai/base"

ai.Seeking = class(SleepableAI)
ai.Seeking.TYPE = "ai.Seeking"

function ai.Seeking:__init(data)
    SleepableAI.__init(self, data)
    assert(data.target)
    self.target     = data.target
end

function ai.Seeking:update()
    SleepableAI.update(self)
    --print("ai.Seeking update", self:getActor().uuid)
    if self.active then
        -- do the seeking logic
        --print("ai.Seeking is active", self:getActor().uuid)
        SleepableAI.sleep(self)
    end
end
