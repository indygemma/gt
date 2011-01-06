utils = {}

local function transform_2dTo3d( x, y )
    return x,0,y
end

local function transform_3dTo2d( x,y,z )
    return x,z
end

local function collect_floor_coords( grid )
    -- collect the coordinates for empty floors
    -- to spawn things randomly later on
    local w = table.getn(grid[1])
    local h = table.getn(grid)
    local result = {}
    for y=1,h do
        for x=1,w do
            local tile = grid[y][x]
            if tile == 0 then
                table.insert(result, {x=x,y=y})
            end
        end
    end
    return result
end

local function random_entry( coords )
    -- returns a random element from a list of things
    local count = table.getn(coords)
    if count > 0 then
        local idx   = math.random( count )
        print("random_entry idx:", idx, " count:", count)
        local entry = coords[idx]
        if entry.node then
            print( "PENGUIN POINTER (random_entry)", entry.node, entry.node._pointer )
        end
        return entry
    end
    return nil
end

utils.transform_2dTo3d = transform_2dTo3d
utils.transform_3dTo2d = transform_3dTo2d
utils.collect_floor_coords = collect_floor_coords
utils.random_entry = random_entry
return utils
