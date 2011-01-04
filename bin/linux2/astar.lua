-- A* Algorithm implemented in Lua by Conrad Indiono
-- Tue Jan  4 03:53:51 CET 2011
--
-- This is a direct translation of the algorithm described in pseudocode here:
-- http://theory.stanford.edu/~amitp/GameProgramming/ImplementationNotes.html
--
GRID = {
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,3,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
    {1,1,0,1,1,0,0,1,1,0,0,1,1,0,0,0,1,0,0,0,1,1},
    {1,1,0,0,0,0,0,1,1,0,0,1,1,0,0,0,1,0,0,2,1,1},
    {1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,1,1},
    {1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,1},
    {1,1,1,1,4,0,0,0,0,0,0,1,1,0,0,0,1,0,0,0,1,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
}

D  = 10 -- horizontal and vertical movement cost
D2 = 14 -- diagonal movement cost
INACCESSABLE_TILE = 1

---- improve table ---

-- find element v of l satisfying f(v)
function table.find(t, f)
  for i, v in ipairs(t) do
    if f(v) then
      return i,v
    end
  end
  return nil
end

-- invert the table
function table.inverse (t)
   local res = { }
   for _, v in ipairs(t) do
       table.insert( res, 1, v )
   end
   return res
end

-- locate the neighbor node inside a list
function neighbor_in(t,node)
    return table.find(t, function(v)
        return v.x == node.x and v.y == node.y
    end)
end

-- for g(node) calculation
function distance(x1,y1,x2,y2)
    return math.abs(x1-y1) + math.abs(y1-y2)
end

-- for 4 possible directions: N, E, S, W
function manhattan_distance(d,x1,y1,x2,y2)
    return d * (math.abs(x1-x2) + math.abs(y1-y2))
end

-- for diagonal movements (8 possible directions)
function chebyshev_distance(d,x1,y1,x2,y2)
    return d * math.max(math.abs(x1-x2), math.abs(y1-y2))
end

-- improved diagonal movements
function diagonal_distance(d1,d2,x1,y1,x2,y2)
    -- d2 is the diagonal cost
    local h_diagonal = math.min(math.abs(x1-x2), math.abs(y1-y2))
    local h_straight = math.abs(x1-x2) + math.abs(y1-y2)
    return d2 * h_diagonal + d1 * (h_straight - 2*h_diagonal)
end

-- nodes are ordered by their cost attribute
function sort(list)
    table.sort( list, function(a,b) return a.cost < b.cost end )
    return list
end

function printnodes(list)
    table.foreach( list, function(k,v) print(k,v.x,v.y,v.cost) end )
end

function findneighbors(grid,node)
    -- returns a list of neighbor nodes that are valid
    -- walls are defined as INACCESSABLE_TILE, every other value is acceptable
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
        if newnode.x >= 1 or newnode.x <= w or
           newnode.y >= 1 or newnode.y <= h then
            -- now check whether this node contains a valid tile
            if grid[newnode.y][newnode.x] ~= INACCESSABLE_TILE then
                table.insert(result, 1, newnode)
            end
        end
    end
    return result
end

function findpath(grid,x1,y1,x2,y2)
    local open  = {}
    local close = {}
    local w     = table.getn(grid[1])
    local h     = table.getn(grid)

    -- add the initial node to the open list
    local initial = { x=x1, y=y1, parent=nil, cost=0 }
    table.insert(open, 1, initial)

    local current = nil
    repeat
        current = table.remove( open, 1 )
        table.insert(close, 1, current)
        for i,neighbor in ipairs(findneighbors(grid,current)) do
            local cost = distance(x1,y1,current.x,current.y) + D
            local open_idx,_  = neighbor_in( open, neighbor )
            local close_idx,_ = neighbor_in( close, neighbor )
            if open_idx ~= nil and
               cost < distance(x1,y1,neighbor.x,neighbor.y) then
               table.remove( open, idx )
            elseif close_idx ~= nil and
               cost < distance(x1,y1,neighbor.x,neighbor.y) then
              table.remove( close, idx )
            elseif open_idx == nil and close_idx == nil then
                neighbor.cost = cost + diagonal_distance(D,D2,
                                                         neighbor.x,neighbor.y,
                                                         x2,y2)
                neighbor.parent = current
                table.insert( open, neighbor )
                open = sort( open )
            end
        end
    until current.x == x2 and current.y == y2
    local result = {}
    local parent = current
    repeat
        table.insert( result, parent )
        parent = parent.parent
    until parent == nil
    return table.inverse( result )
end

printnodes(findpath(GRID, 3,2,20,4))
