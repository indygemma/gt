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

Level2 = class(Actor)
Level2.name = "level2"
Level2.aspects = {
    { Map2D,  {
            sizes = { x=20, y=20 },
            origin = { x=0, y=0 },
            grid = {
            --                     1 1 1 1 1 1 1 1 1 1 2 2 2
            --   1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
                {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}, -- 1
                {1,1,3,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}, -- 2
                {1,1,0,1,1,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,1,1}, -- 3
                {1,1,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,2,1,1}, -- 4
                {1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1}, -- 5
                {1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,1}, -- 6
                {1,1,1,1,4,0,0,0,0,0,0,1,1,0,0,0,1,0,0,0,1,1}, -- 7
                {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}, -- 8
            }
        }
    }
}
ASPECT_MANAGER:registerActor(Level2)

Level = class(Actor)
Level.name = "level2"
Level.aspects = {
    { Map2D,  {
            sizes = { x=20, y=20 },
            origin = { x=0, y=0 },
            grid = {
            --                     1 1 1 1 1 1 1 1 1 1 2 2 2
            --   1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
                {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}, -- 1
                {1,2,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1}, -- 2
                {1,0,0,0,1,0,0,0,0,0,0,1,1,0,0,0,0,1,1,1,0,1}, -- 3
                {1,0,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,2,0,0,1}, -- 4
                {1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1}, -- 5
                {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1}, -- 6
                {1,0,0,0,4,0,0,0,0,0,1,0,0,0,0,0,1,1,0,0,0,1}, -- 7
                {1,0,0,0,0,0,0,0,0,4,1,4,0,0,0,0,0,1,1,0,0,1}, -- 8
                {1,0,0,0,0,0,0,0,0,4,1,4,0,0,0,0,0,0,0,0,0,1}, -- 9
                {1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1}, -- 10
                {1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,0,0,0,0,1}, -- 11
                {1,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1}, -- 12
                {1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1}, -- 13
                {1,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,1,1,1,0,0,1}, -- 14
                {1,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,1,2,0,0,1}, -- 15
                {1,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1}, -- 16
                {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}, -- 17
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
            scale    = { 0.2, 0.2, 0.2 }
        }
    }
}
ASPECT_MANAGER:registerActor(Wall)

Floor = class(Actor)
Floor.name = "floor"
Floor.aspects = {
    -- anything but 1 is rendered as floor, with a -1 z-offset
    { MapItem, { f=function(i) return i ~= 1 end } },
    { Position, { z_offset = -20 } },
    { Visual,  {
            mesh     = "cube.mesh",
            material = "Examples/Rockwall",
            scale    = { 0.2, 0.2, 0.2 }
        }
    },
    { Target, { name="floor" } }, -- let other actors target this as "floor"
}
ASPECT_MANAGER:registerActor(Floor)

Animal = class(Actor)
Animal.name = "penguin"
Animal.aspects = {
    { MapItem, { id=3 }},
    Position,
    Movement,
    { Visual,  {
            mesh = "penguin.mesh",
            scale = { 0.3, 0.3, 0.3 }
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
            sleep=0.02 -- update every 250ms
        }
    },
    { ai.Idle, {
            -- we enter this state when we've reached food, update
            -- every 750ms, and decrease the hunger level by 15 each
            -- tick
            sleep=0.02,
            update=function(self)
                print("Decreasing hunger by", 5, self:getActor().uuid)
                self:getActor():getAspect(Hunger):decrease(5)
                if self:getActor():getAspect(Hunger):level() <= 20 then
                    print("Enough eating. looking for toy")
                    self:getActor():getAspect(Targeting):setTarget("toy")
                end
            end,
            activate=function(self)
                local targeting = self:getActor():getAspect(Targeting)
                print("targeting:currentTarget()", self:getActor():getAspect(Targeting):currentTarget(), targeting, self:getActor().uuid)
                return targeting:distanceScore() < 5 and
                       targeting:currentTarget() == "food"
            end
        }
    },
    { ai.Seeking, {
            sleep=0.02,
            target="toy",
            -- this tranlates to: "seek toy once we're below 25
            -- hunger level". This is the default state, because
            -- we start with hunger level of 0.
            activate=function(self)
                return not self:getActor():getAspect(Hunger):isCritical()
                and self:getActor():getAspect(Targeting):currentTarget() == "toy"
            end,
        }
    },
    { Hunger,  { level=0, increase_rate=0.5, critical=150 } }
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
            scale = { 0.05, 0.05, 0.05 },
            material = "Examples/SphereMappedRustySteel",
        }
    },
    Sleepable,
    { Target, { name="toy" } },
    --{ Targeting, { targets={ "floor" } } },
    -- make it wander around looking for random floor tiles,
    -- but only if not being played by animals
    --{ ai.Seeking, {
            --target= "floor",
            --activate=function(self)
                --return not self:getActor():getAspect(Target):targeted()
            --end,
            --sleep=2.5
        --}
    --},
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
            scale = { 2, 2, 2 }
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
        activate = { MouseInput, MouseInput.RIGHT_MOUSE_CLICK },
        actor_class = Toy
    }},
    --{ LevelSpawn, {
        --activate = { KeyboardInput, KeyboardInput.SPACE },
        --actor_class = Level2
    --}},
    MouseInput,
    KeyboardInput
}
ASPECT_MANAGER:registerActor(RandomActorSpawner)
