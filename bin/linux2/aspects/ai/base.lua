require "aspects/base"

ai = {} -- global ai namespace

AI = class(Aspect)
AI.TYPE = "AI"

function AI:__init()
    Aspect.__init(self)
end

return ai
