require "actor"
require "aspects/target"
require "aspects/visual"
require "aspects/ai/animal"
require "aspects/ai/toy"
require "aspects/movement"
require "aspects/position"
require "aspects/sleep"
require "aspects/hunger"
require "aspects/map"
require "aspects/input"
require "aspects/ai/seeking"
require "aspects/ai/idle"

Level = class(Actor)
Level.name = "level"
Level.aspects = {
    { Map2D,  {
            origin = { 0, 0 },
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
}
ASPECT_MANAGER:registerActor(Level)

Wall = class(Actor)
Wall.name = "wall"
Wall.aspects = {
    { MapItem, { id=1 } },
    Position,
    { Visual,  {
            mesh     = "cube.mesh",
            material = "Examples/Rocky",
            scale    = { 0.01, 0.01, 0.01 }
        }
    }
}
ASPECT_MANAGER:registerActor(Wall)

Floor = class(Actor)
Floor.name = "floor"
Floor.aspects = {
    -- anything but 1 is rendered as floor, with a -1 z-offset
    { MapItem, { f=function(i) return i ~= 1 end } },
    { Position, { z_offset = -1 } },
    { Visual,  {
            mesh     = "cube.mesh",
            material = "Examples/Rockwall",
            scale    = { 0.01, 0.01, 0.01 }
        }
    },
    { Target, { name="floor" } }, -- let other actors target this as "floor"
}
ASPECT_MANAGER:registerActor(Floor)

Animal = class(Actor)
Animal.name = "penguin"
Animal.aspects = {
    { MapItem, { id=3 }},
    { Position, { z_offset = 5 } },
    Movement,
    { Visual,  {
            mesh = "penguin.mesh",
            scale = { 0.015, 0.015, 0.015 }
        }
    },
    Sleepable,
    { Targeting, { current="toy", targets = {"food", "toy"} } },
    { ai.Seeking, {
            target= "food",
            -- this translates to: "seek food once we're hungry"
            activate=function(self)
                return self:getActor():getAspect(Hunger):isCritical()
            end,
            sleep=2.25 -- update every 250ms
        }
    },
    { ai.Idle, {
            -- we enter this state when we've reached food, update
            -- every 750ms, and decrease the hunger level by 15 each
            -- tick
            sleep=2.75,
            update=function(self)
                self:getAspect(Hunger):decrease(15)
            end,
            activate=function(self)
                local targeting = self:getActor():getAspect(Targeting)
                return targeting:distanceScore() < 2 and
                       targeting:currentTarget() == "food"
            end
        }
    },
    { ai.Seeking, {
            sleep=1.0,
            target="toy",
            -- this tranlates to: "seek toy once we're below 25
            -- hunger level". This is the default state, because
            -- we start with hunger level of 0.
            activate=function(self)
                return self:getActor():getAspect(Hunger):level() < 25 and
                       self:getActor():getAspect(Targeting):currentTarget() == "toy"
            end,
        }
    },
    { Hunger,  { level=0, increase_rate=5, critical=75 } }
}
ASPECT_MANAGER:registerActor(Animal)

Toy = class(Actor)
Toy.name = "toy"
Toy.aspects = {
    { MapItem, { id=2 }},
    Movement,
    Position,
    { Visual, {
            mesh = "sphere.mesh",
            scale = { 0.0025, 0.0025, 0.0025 },
            material = "Examples/SphereMappedRustySteel",
        }
    },
    Sleepable,
    { Target, { name="toy" } },
    { Targeting, { targets={ "floor" } } },
    -- make it wander around looking for random floor tiles,
    -- but only if not being played by animals
    { ai.Seeking, {
            target= "floor",
            activate=function(self)
                return not self:getActor():getAspect(Target):targeted()
            end,
            sleep=2.5
        }
    },
    { ai.Idle, {
            activate=function(self)
                return self:getActor():getAspect(Target):distanceScore() < 2
            end,
            sleep=2.75
        }
    }
}
ASPECT_MANAGER:registerActor(Toy)

Food = class(Actor)
Food.name = "food"
Food.aspects = {
    { MapItem, { id=4 } },
    Position,
    { Visual, {
            mesh = "fish.mesh",
            scale = { 0.1, 0.1, 0.1 }
        }
    },
    { Target, { name="food" } }
}
ASPECT_MANAGER:registerActor(Food)

RandomActorSpawner = class(Actor)
RandomActorSpawner.name = "random_actor_spawner"
RandomActorSpawner.aspects = {
    { RandomMapSpawn, {
        candidate_tiles = 0,
        activate = { MouseInput, MouseInput.LEFT_MOUSE_CLICK },
        actor_class = Animal
    }},
    { RandomMapSpawn, {
        candidate_tiles = 0,
        activate = { KeyboardInput, KeyboardInput.SPACE },
        actor_class = Toy
    }},
    MouseInput,
    KeyboardInput
}
ASPECT_MANAGER:registerActor(RandomActorSpawner)
