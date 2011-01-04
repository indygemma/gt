require "luaspec"
require "bt"

describe["A Behaviour Tree"] = function()

    before = function()
        bt = BT:new()
    end

    it["assert that 0 equals 0"] = function()
        expect(0).should_be(0)
    end

end
