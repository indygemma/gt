print "hi world!"

GRID = {
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},

game.on_mouseclick = function(btn, x, y, z)
    if btn == 1 then
        print("Left mouse clicked!")
    elseif btn == 2 then
        print("Right mouse clicked!")
    end
end

game.app.on_scenesetup = function()
    print("Setting up scene...")
    game.app.add_entity("fish", "fish.mesh", "fish01", 50, 50, 50)
    game.app.add_entity("fish 2", "fish.mesh", "fish02", -50, -50, -50)
    game.app.add_entity("cube", "cube.mesh", "cube01", 0,0,0)
end
