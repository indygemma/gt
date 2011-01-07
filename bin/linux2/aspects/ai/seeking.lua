ai = require "aspects/ai/base"

ai.Seeking = class(AI)
ai.Seeking.TYPE = "ai.Seeking"

function ai.Seeking:__init(data)
    AI.__init(self)
end

