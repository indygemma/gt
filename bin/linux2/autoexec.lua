require "scheduler"
require "entity"

local GRID = {
--   1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 0
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}, -- 1
    {1,1,3,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}, -- 2
    {1,1,0,1,1,0,0,1,1,0,0,1,1,0,0,0,1,0,0,0,1,1}, -- 3
    {1,1,0,0,0,0,0,1,1,0,0,1,1,0,0,0,1,0,0,2,1,1}, -- 4
    {1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,1,1}, -- 5
    {1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,1}, -- 6
    {1,1,1,1,4,0,0,0,0,0,0,1,1,0,0,0,1,0,0,0,1,1}, -- 7
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}, -- 8
}

game.on_mouseclick = function(btn, x, y, z)
    if btn == 1 then
        print("Left mouse clicked!")
    elseif btn == 2 then
        print("Right mouse clicked!")
    end
end

local node

local function create_entity(name, mesh, x, y, z)
    local node = game.app.add_entity("cube02", "cube.mesh", "cube02", 1,0,0)
    node:setScale(0.01, 0.01, 0.01)
    node:getAttachedObject(0):setMaterialName("Examples/Rockwall")
end

game.app.on_scenesetup = function()
    print("Setting up scene...")
    game.app.add_entity("fish", "fish.mesh", "fish01", 50, 50, 50)
    game.app.add_entity("fish 2", "fish.mesh", "fish02", -50, -50, -50)

    for x=0,50 do
        for y=0,50 do
            print("cubex"..x..y)
            node = game.app.add_entity("cubex"..x.."y"..y, "cube.mesh", "cubex"..x.."y"..y, x*1,0,y*1)
            node:setScale(0.01, 0.01, 0.01)
            node:getAttachedObject(0):setMaterialName("Examples/Rockwall")
        end
    end

    --for i=0,50 do
        --node = game.app.add_entity("cubey"..i, "cube.mesh", "cubey"..i, i*1,i*1,i*1)
        --node:setScale(0.01, 0.01, 0.01)
        --node:getAttachedObject(0):setMaterialName("Examples/Rockwall")
    --end

    --for i=0,50 do
        --node = game.app.add_entity("cubez"..i, "cube.mesh", "cubez"..i, 0,i*1,0)
        --node:setScale(0.01, 0.01, 0.01)
        --node:getAttachedObject(0):setMaterialName("Examples/Rockwall")
    --end

    print("End of scene setup")
end

game.app.on_update = function()
    --print("scheduler step", scheduler.step())
    scheduler.step()
end
