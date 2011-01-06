require "actor"
require "aspects/target"
require "aspects/visual"
require "aspects/ai/animal"
require "aspects/movement"
require "aspects/position"
require "aspects/sleep"
require "aspects/hunger"
require "aspects/map"

Level = Actor()
Level.aspects = {
    2DMap {
        grid = {
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
    }
}
Level:register()

Wall = Actor("wall")
Wall.aspects = {
    MapItem 1,
    Position(),
    Visual {
        mesh     = "cube.mesh",
        material = "Examples/Rocky",
        scale    = { 0.01, 0.01, 0.01 }
    }
}
Wall:register()

Floor = Actor("floor")
Floor.aspects = {
    -- anything but 1 is rendered as floor
    MapItem function(i) return i != 1 end,
    Position { z_offset = -1 },
    Visual {
        mesh     = "cube.mesh",
        material = "Examples/Rockwall"
        scale    = { 0.01, 0.01, 0.01 }
    },
    Target("floor") -- let other actors target this as "floor"
}
Floor:register()

Animal = Actor("penguin")
Animal.aspects = {
    MapItem 3,
    Position(),
    Movement(),
    MouseInput(),
    -- randomly spawn more of my type when left mouse is clicked
    RandomMapSpawn {
        candidate_tiles = 0,
        activate = MouseInput.LEFT_MOUSE_CLICK
    },
    Visual {
        mesh = "penguin.mesh",
        scale = { 0.015, 0.015, 0.015 }
    },
    Sleepable(),
    Targeting { "food", "toy" },
    ai.Animal(),
    Hunger { 100, -5 }
}
Animal:register()

Toy = Actor("toy")
Toy.aspects = {
    MapItem 2,
    Movement(),
    Position(),
    MouseInput(),
    RandomMapSpawn {
        candidate_tiles = 0,
        activate = MouseInput.RIGHT_MOUSE_CLICK
    },
    Visual = {
        mesh = "sphere.mesh",
        scale = { 0.0025, 0.0025, 0.0025 }
    },
    Sleepable(),
    Target { "toy" },
    Targeting { "floor" },
    ai.Toy() -- make it wander around looking for random floor tiles, but only if not being played by animals
}
Toy:register()

Food = Actor("food")
Food.aspects = {
    MapItem 4,
    Position(),
    Visual = {
        mesh = "fish.mesh",
        scale = { 0.1, 0.1, 0.1 }
    },
    Target( "food" )
}
Food:register()

