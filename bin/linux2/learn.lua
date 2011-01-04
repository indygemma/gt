GRID = {
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

function findneighbors(grid,node)
    -- returns a list of neighbor nodes that are valid
    -- walls are defined as 1, every other value is acceptable
    local w = table.getn(grid[1])
    local h = table.getn(grid)
    local result = {}
    local valid_coords = {
        {-1,-1}, {0,-1}, {1,-1},
        {-1, 0},         {1, 0},
        {-1, 1}, {0, 1}, {1, 1}
    }
    -- transform valid_coords to real coords
    local tile = nil
    for k,v in ipairs(valid_coords) do
        local newnode = { x=node.x + v[1], y=node.y + v[2] }
        if newnode.x < 1 or newnode.x > w or
           newnode.y < 1 or newnode.y > h then
            -- invalid
            print("invalid neighbor node:", newnode.x, newnode.y)
        else
            -- now check whether this node contains a valid tile
            tile = grid[newnode.y][newnode.x]
            print("checking", newnode.x, newnode.y)
            if tile ~= 1 then
                print("added to result", newnode.x, newnode.y)
                table.insert(result, 1, newnode)
            end
        end
    end
    return result
end

print(findneighbors(GRID, {x=20,y=5}))
