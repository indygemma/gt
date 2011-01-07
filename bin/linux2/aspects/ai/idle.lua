ai = require "aspects/ai/base"

ai.Idle = class(AI)
ai.Idle.TYPE = "ai.Idle"

function ai.Idle:__init(data)
    AI.__init(self)
end

