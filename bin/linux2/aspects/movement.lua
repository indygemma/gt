require "aspects/base"

Movement = class(Aspect)
Movement.TYPE = "Movement"

function Movement:__init()
    Aspect.__init(self)
    self.speed     = 2
    self.velocity  = 0
    self.direction = { 1, 0, 0 }
end

function Movement:move( x, y )
    -- TODO: implement movement logic in 2D
    assert(false)
end
