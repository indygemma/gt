scheduler = require "scheduler"
utils = require "utils"
require "actor"
require "actors/animal"
require "actors/toy"
require "actors/food"

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

WORLD = {
    GRID = GRID,
    FLOOR_COORDS = utils.collect_floor_coords( GRID ),
    ANIMALS = {}, -- list of spawned animals
    FOODS = {},   -- list of spawned food
    TOYS = {},    -- list of spawned toys
    TEST = {}
}

local function spawnAnimal( x, y )
    local count = table.getn( WORLD.ANIMALS )
    penguin = game.app.add_entity("penguin"..count, "penguin.mesh", "penguin"..count, x,0,y)
    table.insert( game.UNCOLLECTABLES, penguin )
    penguin:setScale( 0.015, 0.015, 0.015 )
    x,y,z = penguin:getPosition()
    test = {}
    print( "TEST address", test )
    print("WORLD", WORLD)
    print("WORLD.ANIMALS", WORLD.ANIMALS)
    print("AJSDNALJDNALSJND", x, y, z )
    --table.foreach( penguin, print)
    print( "penguin.getPosition", penguin.getPosition )
    --print( "PENGUIN POINTER", penguin, penguin._pointer )
    animal = Animal( WORLD, "penguin"..count)
    animal:set_node(penguin)
    --print( "PENGUIN POINTER", animal.node, animal.node._pointer )
    table.insert( WORLD.ANIMALS, animal )
    local idx = table.getn( WORLD.ANIMALS )
    --print( "PENGUIN POINTER", WORLD.ANIMALS[idx].node, WORLD.ANIMALS[idx].node._pointer )
    table.insert( WORLD.TEST, test )
    return animal
end

local function spawnToy( x, y )
    print ("CREATING NEW TOY @", x, " ", y)
    local count = table.getn( WORLD.TOYS )
    ball = game.app.add_entity("toy"..count, "sphere.mesh", "toy"..count, x, 0, y)
    table.insert( game.UNCOLLECTABLES, ball )
    ball:setScale( 0.0025, 0.0025, 0.0025 )
    ball:getAttachedObject(0):setMaterialName("Examples/SphereMappedRustySteel")
    --print( "TOY POINTER", ball, ball._pointer )
    toy = Toy( WORLD, "toy"..count )
    toy:set_node(ball)
    table.insert( WORLD.TOYS, toy )
    local idx = table.getn( WORLD.TOYS )
    --print( "TOY POINTER", WORLD.TOYS[idx].node, WORLD.TOYS[idx].node._pointer )
    return toy
end

local function spawnFood( x, y )
    local count = table.getn(WORLD.FOODS)
    local fish = game.app.add_entity("fish"..count, "fish.mesh", "fish"..count, x, 0, y)
    table.insert( game.UNCOLLECTABLES, fish )
    fish:setScale( 0.1, 0.1, 0.1 )
    food = Food( WORLD, "food"..count )
    food:set_node(fish)
    table.insert( WORLD.FOODS,food )
    return food
end

-- valid materials are
-- Examples/Rockwall
-- Examples/SphereMappedRustySteel
-- Examples/Rocky

local function render_block(x, y, z, material)
    material = material or "Examples/Rocky"
    local node = game.app.add_entity("cubex"..x.."y"..y, "cube.mesh", "cubex"..x.."y"..y, x*1,z,y*1)
    table.insert( game.UNCOLLECTABLES, node )
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
            if tile == 3 then
                spawnAnimal( x, y )
            elseif tile == 2 then
                spawnToy( x, y )
            elseif tile == 4 then
                spawnFood( x, y )
            end
        end
    end
    io.close()
end

game.app.on_scenesetup = function()
    print("Setting up scene...")

    render_labyrinth(WORLD.GRID)

    print("End of scene setup")
end

--scheduler.register(function()
    --while 1 do
        --for i,v in ipairs(WORLD.ANIMALS) do
            --print("seeking toy ", v.name)
            --v:print_pos()
        --end
        --coroutine.yield()
    --end
--end, {})

game.app.on_update = function()
    --print("scheduler step", scheduler.step())
    --print(game.UNCOLLECTABLES)

    -- run the default scheduler
    scheduler.step()

    -- run print pos directly
    --print("on update")
    --for i,v in ipairs(WORLD.ANIMALS) do
        --print("seeking toy ", v.name)
        --v:print_pos()
    --end
end

game.on_mouseclick = function(btn, x, y, z)
    if btn == 1 then
        print("Left mouse clicked!")
        local c = utils.random_entry( WORLD.FLOOR_COORDS )
        if c then
            print(string.format("randomly spawning new ANIMAL at %d %d\n", c.x, c.y))
            spawnAnimal( c.x, c.y )
        end
    elseif btn == 2 then
        print("Right mouse clicked!")
        local c = utils.random_entry( WORLD.FLOOR_COORDS )
        if c then
            print(string.format("randomly spawning new TOY at %d %d\n", c.x, c.y))
            spawnToy( c.x, c.y )
        end
    end
end

