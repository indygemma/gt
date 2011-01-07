require "aspects/base"

Position = class(Aspect)
Position.TYPE = "Position"

function Position:__init(data)
    Aspect.__init(self)
    -- optional data options:
    self.x_offset = data.x_offset or 0
    self.y_offset = data.y_offset or 0
    self.z_offset = data.z_offset or 0
    self.x = data.x or 0
    self.y = data.y or 0
    self.z = data.z or 0
end

function Position:set( x, y, z )
    z = z or 0
    self.x = self.x_offset + x
    self.y = self.y_offset + y
    self.z = self.z_offset + z
end
