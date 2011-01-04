A = require "astar"

-- EXAMPLE USAGE --
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

-- A.printnodes(A.findpath(GRID, 3,2,20,4))

require "entity"

a = Animal("angie")
a2 = Animal("brian")

function customloop(a,b,c)
    local snapshot = os.clock()
    local s1 = os.clock()
    local count = 0
    while 1 do
        count = count + 1
        print "----"
        print( string.format("just waited %.2f seconds", os.clock()-s1))
        print( string.format("Elapsed time %.2f", os.clock() - snapshot))
        print("adhoc coroutine", count)
        print( a,b,c )
        print "----"
        s1 = os.clock()
        coroutine.yield({sleep=0.5})
    end
end

scheduler.register(customloop, {1,2,3})

for i=1,5000000 do
    scheduler.step()
end
