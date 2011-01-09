require "aspects/base"

-- The visual aspect controls how the actor is visually
-- represented on screen. In this case, we're using Ogre
-- SceneNodes as the basis for manipulating the visual aspect.
Visual = class(Aspect)
Visual.TYPE = "Visual"

function Visual:__init(data)
    Aspect.__init(self)
    assert(data.mesh) -- the mesh is always required
    self.mesh     = data.mesh
    self.scale    = data.scale or { 1, 1, 1 }
    self.material = data.material

    self.scene_node = nil
end

function Visual:setup()
    local pos = self:getActor():getAspect(Position)
    self.scene_node = game.app.add_entity(
                        self:getActor().uuid,
                        self.mesh,
                        self:getActor().uuid,
                        pos.x,
                        pos.z,
                        pos.y)
    self.scene_node:setScale( self.scale[1], self.scale[2], self.scale[3] )
    if self.material then
        self.scene_node:getAttachedObject(0):setMaterialName(self.material)
    end
end

