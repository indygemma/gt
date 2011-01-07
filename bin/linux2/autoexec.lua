require "actors/sample"

game.app.on_scenesetup = function()
    print("Setting up scene...")
    local level = ACTOR_MANAGER:create(Level) -- create a level instance
    ACTOR_MANAGER:create(RandomActorSpawner)
    print("End of scene setup")
end

game.app.on_update = function()
    --ASPECT_MANAGER:update()
    ACTOR_MANAGER:update()
end

game.on_mouseclick = function( btn, x, y )
    for i,aspect in ipairs(ASPECT_MANAGER:getAspect(MouseInput)) do
        print(" HANDLE MOUSE CLICK ", btn, x, y, aspect)
        aspect:on_mouseclick( btn, x, y)
    end
end
