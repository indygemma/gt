require "aspects/base"

Movement = class(Aspect)
Movement.TYPE = "Movement"

function Movement:__init()
    Aspect.__init(self)
    self.speed     = 1
    self.velocity  = 0
    self.direction = { 1, 0, 0 }
end

function Movement:move( x, y )
    -- TODO: implement movement logic in 2D
    -- change orientation to face the target
    self:getActor():getAspect(Visual).scene_node:lookAt( x, 0, y )
    local dir= { x=0,y=0 }
    local posX,posY,posZ = self:getActor():getAspect(Position):getPos()
    --posX = math.floor(posX)
    --posY = math.floor(posY)
    --print( "move", posX, posY, x, y )
    local dx = x - posX
    local dy = y - posY
    if dx > 1 then dir.x = 1 else dir.x = -1 end
    if dy > 1 then dir.y = 1 else dir.y = -1 end
    local nx = self.speed * dir.x
    local ny = self.speed * dir.y
    --print( "dx, dy, nx, ny", dx, dy, nx, ny )
    self:getActor():getAspect(Visual).scene_node:translate( nx,0,ny )
end
