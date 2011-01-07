require "aspects/base"

ai = {} -- global ai namespace

AI = class(Aspect)
AI.TYPE = "AI"

function AI:__init(data)
    Aspect.__init(self)
    assert(data.activate)
    self.active     = false
    self.activate_f = data.activate
end

function AI:update()
    if self.active == false and self.activate_f(self) then
        print(" ACTIVATED AI ", self.TYPE, self:getActor().uuid )
        self.active = true
    end
end

function AI:isActive()
    return self.active
end

-- we need a base sleepable based AI
SleepableAI = class(AI)
SleepableAI.TYPE = "SleepableAI"

function SleepableAI:__init(data)
    AI.__init(self, data)
    self.sleep = data.sleep
end

function SleepableAI:setup()
    if self.sleep then
        self.sleepable = self:getActor():getAspect(Sleepable)
    end
end

function SleepableAI:sleep()
    if self.sleepable then
        local now = os.clock()
        print("SLEEPING for", self.sleep, "@", now, " until ", now+self.sleep, self:getActor().uuid )
        self.sleepable:sleep(self.sleep)
    end
end

return ai
