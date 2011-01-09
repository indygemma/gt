require "aspects/base"

ai = {} -- global ai namespace

AI = class(Aspect)
AI.TYPE = "AI"

function AI:__init(data)
    Aspect.__init(self)
    assert(data.activate)
    self.active      = false
    self.last_active = false
    self.activate_f  = data.activate
    self.on_update_f = data.update
end

function AI:update()
    self.active = self.activate_f(self)
    if self.active and self.last_active == false then
        print(" ACTIVATED AI ", self.TYPE, self:getActor().uuid )
        self:on_activate()
    elseif not self.active and self.last_active then
        print(" DEACTIVATED AI ", self.TYPE, self:getActor().uuid )
        self:on_deactivate()
    end
    if self.active then
        if self.on_update_f then
            self.on_update_f(self)
        end
    end
    self.last_active = self.active
end

function AI:on_activate()
    -- subclasses can implement this to execute any logic on activation
end

function AI:on_deactivate()
    -- subclasses can implement this to execute any logic on deactivation
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
        self.sleepable:sleep(self.sleep)
    end
end

return ai
