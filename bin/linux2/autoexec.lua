require "scheduler"
require "entity"

local GRID = {
--                     1 1 1 1 1 1 1 1 1 1 2 2 2
--   1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
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

-- valid materials are
-- Examples/Rockwall
-- Examples/SphereMappedRustySteel
-- Examples/Rocky

local function render_block(x, y, z, material)
    material = material or "Examples/Rocky"
    local node = game.app.add_entity("cubex"..x.."y"..y, "cube.mesh", "cubex"..x.."y"..y, x*1,z,y*1)
    node:setScale(0.01, 0.01, 0.01)
    node:getAttachedObject(0):setMaterialName(material)
end

local function render_labyrinth(grid)
    local w = table.getn(grid[1])
    local h = table.getn(grid)

    print("w:", w, "h:", h)
    io.output("lua.log")
    for y=1,h do
        for x=1,w do
            local tile = grid[y][x]
            if tile == 1 then
                render_block(x,y,0)
            else
                render_block(x,y,-1, "Examples/Rockwall")
            end
        end
    end
    io.close()
end

game.app.on_scenesetup = function()
    print("Setting up scene...")
    -- somehow removing the first fish, makes the first 2 wall blacks not renderable??
    game.app.add_entity("fish", "fish.mesh", "fish01", 50, 50, 50)
    local penguin = game.app.add_entity("penguin", "penguin.mesh", "penguin01", 0,0,-5)
    penguin:setScale(0.015, 0.015, 0.015)
    --game.app.add_entity("fish 2", "fish.mesh", "fish02", -50, -50, -50)

    render_labyrinth(GRID)

    print("End of scene setup")
end

game.app.on_update = function()
    --print("scheduler step", scheduler.step())
    scheduler.step()
end
