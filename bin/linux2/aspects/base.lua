require "class"

-- Base Class for all aspects
Aspect = class()

function Aspect:__init()
end

function Aspect:setup()
    -- called when the aspect is created on actor construction
    -- setup anything that is required by subclass aspects here
    -- after its construction
end

function Aspect:postSetup()
    -- called after every aspect inside an actor has been setup
end

function Aspect:update()
    -- always re-implented by subclasses
end

function Aspect:setActor(actor)
    self.actor = actor
end

function Aspect:getActor()
    return self.actor
end

-- The main container for all aspect instances within actors
AspectManager = class()

function AspectManager:__init()
    -- actor CLASSES, with their associated aspect CLASSES
    -- contains schema-level information
    self.actors  = {} -- name -> actor class
    -- aspect INSTANCES
    self.aspects = {}
    -- aspect INSTANCES by TYPE
    self.aspects_by_type = {}
end

function AspectManager:registerActor( actor )
    -- register the actor class, and all the associated
    -- aspect classes. This is handy for later when querying
    -- all those aspect classes with getAspectClasses( class )
    --table.insert( self.actors, actor )
    self.actors[actor.name] = actor
end

function AspectManager:getActorClass( actor_name )
    return self.actors[actor_name]
end

function AspectManager:getActorsWithAspectClass( aspect_class )
    -- return all aspect classes of the given type
    local result = {}
    for name,actor in pairs(self.actors) do
        local matching_aspect = actor:getAspectClass(aspect_class)
        if matching_aspect ~= nil then
            result[actor] = matching_aspect
        end
    end
    return result
end

-- add an aspect instance to the registry
function AspectManager:registerAspect( aspect )
    table.insert( self.aspects, aspect )
    if not self.aspects_by_type[aspect.TYPE] then
        self.aspects_by_type[aspect.TYPE] = {}
    end
    table.insert( self.aspects_by_type[aspect.TYPE], aspect )
end

-- retrieve all aspect instances of a given type
function AspectManager:getAspect( typename )
    typename = typename.TYPE or typename
    return self.aspects_by_type[ typename ]
end

-- update all relevant aspect instances
function AspectManager:update()
    -- update sequence
end

-- our global aspect manager. one and only
ASPECT_MANAGER = AspectManager()
