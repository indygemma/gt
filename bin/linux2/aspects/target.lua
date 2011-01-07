require "aspects/base"

-- Actors using this aspect are targetable by other actors
-- using the Targeting aspect
Target = class(Aspect)
Target.TYPE = "Target"

function Target:__init( data )
    Aspect.__init(self)
    assert( data.name ) -- always required
    self.name = name
    self.is_targeted = false
end

function Target:targeted()
    return self.is_targeted
end

function Target:distanceScore()
    -- TODO: implement this
    return 100
end

-- Targeting aspect implements the actual targeting logic
Targeting = class(Aspect)
Targeting.TYPE = "Targeting"

function Targeting:__init( data )
    Aspect.__init(self)
    assert( data.targets )
    assert(table.getn(data.targets) > 0)
    self.target_types = targets
    self.target       = data.current or nil
end

function Targeting:distanceScore()
    return 100
end

function Targeting:setTarget( targetname )
    self.target = name
end

function Targeting:currentTarget()
    return self.target
end

function Targeting:update()
end
