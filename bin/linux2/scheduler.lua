-- scheduler.lua
--
-- A simple microthread scheduler for coroutines.
-- e.g Entity update methods run as coroutines
--

print (1)

scheduler = {}

local _coros = {} -- registered coroutines

local function register(f, args)
    -- register a function as a coroutine to be scheduled.
    -- sample usages:
    --
    --   scheduler.register( self.update, {self} )
    --   scheduler.register( self.update )
    --   scheduler.register( self.update, {self, 1,2,3} )
    --
    -- the important thing to remember is that arguments are supplied
    -- inside a table, because luajit does not support variable amount
    -- of arguments.
    table.insert(_coros, { co=coroutine.create(f), args=args })
end

local function step()
    -- execute one step/tick.
    -- coroutines can be suspended into sleep mode by having them
    -- yielding in the following way
    --
    --     coroutine.yield({sleep=0.5})  -- yield for 500ms
    --     coroutine.yield({sleep=0.15}) -- yield for 150ms
    --     courtinue.yield({sleep=2})    -- yield for 2 seconds
    --
    local delete_idx = {}
    local errfree,val
    local timestamp
    for i,v in ipairs(_coros) do
        timestamp = os.clock()
        local status = coroutine.status(v.co)
        if status == "dead" then
            table.insert( delete_idx, i )
        else
            if v.sleep ~= nil then
                local duration = timestamp - v.sleep.timestamp
                if (v.sleep.duration < duration) then
                    v.sleep = nil
                end
            end
            if v.sleep == nil then
                print("EXECUTING CORO", v.co, v.args)
                print("unpacking args:", unpack(v.args))
                print("args", v.args)
                print("args[1]:", v.args[1])
                errfree,val = coroutine.resume(v.co, unpack(v.args))
                if not errfree then
                    print(debug.traceback())
                    print( "coroutine had error:", val )
                else
                    if val ~= nil then
                        if val.sleep ~= nil then
                            --print("SLEEPING FOR", val.sleep, "SECONDS")
                            v.sleep = { timestamp=timestamp,
                                        duration=val.sleep }
                        end
                    end
                end
            end
        end
    end

    -- remove dead coroutines
    for i,idx in ipairs(delete_idx) do
        table.remove( _coros, idx )
    end

    return table.getn( _coros )
end

scheduler._coros   = _coros
scheduler.register = register
scheduler.step     = step
print ("scheduler -- end")
return scheduler
