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

function MouseInput:getStatus( btn )
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

KeyboardInput = class(Aspect)
KeyboardInput.TYPE = "KeyboardInput"

-- define keys here
KeyboardInput.SPACE = "space"

function KeyboardInput:__init()
    Aspect.__init(self)
    self.keystates = {}
end

function KeyboardInput:on_keypressed( key )
    self.keystates[ key ] = true
end

function KeyboardInput:getStatus( key )
    if self.keystates[ key ] then
        return true
    end
    return false
end

function KeyboardInput:update()
    for key,v in pairs(self.keystates) do
        self.keystates[key] = false
    end
end
