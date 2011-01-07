require "aspects/base"

-- Actors using this aspect are targetable by other actors
-- using the Targeting aspect
Target = class(Aspect)
Target.TYPE = "Target"

function Target:__init( data )
    Aspect.__init(self)
    assert( data.name ) -- always required
    self.name = name
end

-- Targeting aspect implements the actual targeting logic
Targeting = class(Aspect)
Targeting.TYPE = "Targeting"

function Targeting:__init( data )
    Aspect.__init(self)
    assert( data.targets )
    assert(table.getn(data.targets) > 0)
    self.target_types = targets
end

