-- A* Algorithm implemented in Lua by Conrad Indiono
-- Tue Jan  4 03:53:51 CET 2011
--
-- This is a direct translation of the algorithm described in pseudocode here:
-- http://theory.stanford.edu/~amitp/GameProgramming/ImplementationNotes.html
--
-- EXAMPLE USAGE
--
--[[

    A = require "astar"

    local GRID = {
    --                     1 1 1 1 1 1 1 1 1 1 2 2 2
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

    A.printnodes(A.findpath(GRID, 3,2,20,4))

--]]

A = {}

local D  = 10 -- horizontal and vertical movement cost
local D2 = 14 -- diagonal movement cost
local INACCESSABLE_TILE = 1

-- [[ table utility functions ]] --

-- find element v of l satisfying f(v)
local function find(t, f)
  for i, v in ipairs(t) do
    if f(v) then
      return i,v
    end
  end
  return nil
end

-- invert the table
local function inverse (t)
   local res = { }
   for _, v in ipairs(t) do
       table.insert( res, 1, v )
   end
   return res
end

-- locate the neighbor node inside a list
local function neighbor_in(t,node)
    return find(t, function(v)
        return v.x == node.x and v.y == node.y
    end)
end

-- [[ Distance Calculation ]] --

-- for g(node) calculation
local function distance(x1,y1,x2,y2)
    return math.abs(x1-y1) + math.abs(y1-y2)
end

-- for 4 possible directions: N, E, S, W
local function manhattan_distance(d,x1,y1,x2,y2)
    return d * (math.abs(x1-x2) + math.abs(y1-y2))
end

-- for diagonal movements (8 possible directions)
local function chebyshev_distance(d,x1,y1,x2,y2)
    return d * math.max(math.abs(x1-x2), math.abs(y1-y2))
end

-- improved diagonal movements
local function diagonal_distance(d1,d2,x1,y1,x2,y2)
    -- d2 is the diagonal cost
    local h_diagonal = math.min(math.abs(x1-x2), math.abs(y1-y2))
    local h_straight = math.abs(x1-x2) + math.abs(y1-y2)
    return d2 * h_diagonal + d1 * (h_straight - 2*h_diagonal)
end

local function g(ox,oy,node)
    return distance(ox,oy,node.x,node.y) + D
end

local function h(node,tx,ty)
    return diagonal_distance(D,D2, node.x,node.y, tx,ty)
end

local function f(node,ox,oy,tx,ty)
    return g(ox,oy,node) + h(node,tx,ty)
end

-- [[ node utilities ]] --

-- nodes are ordered by their cost attribute
local function sort(list)
    table.sort( list, function(a,b) return a.cost < b.cost end )
    return list
end

local function printnodes(list)
    table.foreach( list, function(k,v) print(k,v.x,v.y,v.cost) end )
end

local function findneighbors(grid,node)
    -- returns a list of neighbor nodes that are valid.
    -- walls are defined as INACCESSABLE_TILE, every other value is acceptable
    local w = table.getn(grid[1])
    local h = table.getn(grid)
    local result = {}
    local valid_coords = {
                 {0,-1},
        {-1, 0},         {1, 0},
                 {0, 1},
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

-- [[ path calculation ]] --

local function follow_parent_path( node )
    -- return a list of nodes from a given node, following
    -- the parents subsequently, building a path leading to it
    local result = {}
    local parent = node
    repeat
        table.insert( result, parent )
        parent = parent.parent
    until parent == nil
    return inverse( result )
end

local function findpath(grid,x1,y1,x2,y2)
    local open  = {}
    local close = {}

    -- add the initial node to the open list
    local initial = { x=x1, y=y1, parent=nil }
    initial.cost = f(initial, x1, y1, x2, y2)
    table.insert(open, 1, initial)

    local current = nil
    repeat
        current = table.remove( open, 1 )
        table.insert(close, 1, current)
        for i,neighbor in ipairs(findneighbors(grid,current)) do
            local cost        = g(x1,y1,current)
            local open_idx,_  = neighbor_in( open, neighbor )
            local close_idx,_ = neighbor_in( close, neighbor )
            if open_idx ~= nil and
               cost < g(x1,y1,neighbor) then
               table.remove( open, open_idx )
            elseif close_idx ~= nil and
               cost < g(x1,y1,neighbor) then
              table.remove( close, close_idx )
            elseif open_idx == nil and close_idx == nil then
                neighbor.cost = cost + h(neighbor,x2,y2)
                neighbor.parent = current
                table.insert( open, neighbor )
                open = sort( open )
            end
        end
    until current.x == x2 and current.y == y2
    return follow_parent_path( current )
end

-- export module
A.printnodes = printnodes
A.findpath   = findpath
return A
