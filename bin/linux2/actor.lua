-- actor.lua
--
-- Actor definition with a concurrent update kernel
--

-- simulation goal:
--
--   spawn several animals into the level.
--   spawn several toys into the level.
--   spawn several food stops into the level.
--   animals lock into a random toy in the level and follow them around
--   toys are either caught or not caught. if they are not caught then they pick a random position and try to move to that position on the map
--   if they are caught then they stop at the position
--   if the animal is hungry he chooses to ignore the toy and targets food instead. (random)
--   with time the hunger level of an animal increases
--
require "class"
require "scheduler"
A = require "astar"
utils = require "utils"

Actor = class()

function Actor:__init (world)
    print("ACTOR init")
    self.world = world
    print(self.world)
    if self.update then
        scheduler.register( self.update, {self} )
    end
end

function Actor:hello ()
    print(self.thing)
end

function Actor:set_node(node)
    self.node = node
end

function Actor:get_x()
    x,y,z = self.node:getPosition()
    return x
end

function Actor:get_y()
    x,y,z = self.node:getPosition()
    return z
end

function Actor:get_pos()
    x,_,z = self.node:getPosition()
    return x,y
end
