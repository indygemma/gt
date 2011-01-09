ai = require "aspects/ai/base"
A  = require "astar"

ai.Seeking = class(SleepableAI)
ai.Seeking.TYPE = "ai.Seeking"

function ai.Seeking:__init(data)
    SleepableAI.__init(self, data)
    assert(data.target)
    self.target = data.target
end

function ai.Seeking:on_activate()
    self:getActor():getAspect(Targeting):setTarget(self.target)
end

function ai.Seeking:on_deactivate()
end

function ai.Seeking:update()
    SleepableAI.update(self)
    --print("ai.Seeking update", self:getActor().uuid)
    if self.active then
        self:getActor():getAspect(Targeting):updatePath()
        local x,y = self:getActor():getAspect(Targeting):getNextNodePath()
        if x ~= nil and y ~=nil then
            self:getActor():getAspect(Movement):move(x,y)
        end
        SleepableAI.sleep(self)
    end
end
