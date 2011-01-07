require "aspects/base"

local COUNT = 0

MouseInput = class(Aspect)
MouseInput.TYPE = "MouseInput"

MouseInput.LEFT_MOUSE_CLICK  = 1
MouseInput.RIGHT_MOUSE_CLICK = 2

function MouseInput:__init()
    Aspect.__init(self)
    self.clicked = { [1]=false, [2]=false, [3]=false } -- left middle right
end

function MouseInput:on_mouseclick( btn, x, y )
    COUNT = COUNT + 1
    print(" MOUSE CLICK COUNT: ", COUNT, btn, x, y, self )
    self.clicked[btn] = { x=x, y=y }
end

function MouseInput:getClickStatus( btn )
    if self.clicked[btn] ~= false then
        print(" MOUSE ACTIVATED ", btn, self )
        return self.clicked[btn]
    end
    return false
end

function MouseInput:update()
    self.clicked[1] = false
    self.clicked[2] = false
    self.clicked[3] = false
end
