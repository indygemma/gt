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

Actor = class()

function Actor:__init ()
    assert( self.name ) -- name has to be set at class level by the user
    self.aspect_instances = {} -- list of aspect instances
    self.aspects_by_type  = {} -- WARNING: assumption is that there's only one aspect instance per type
end

function Actor:initializeAspects(on_setup_cb)
    -- initialize the aspects first
    -- on_setup_cb holds a table of aspect.TYPE -> callback
    -- entries to do execute post aspect construction
    -- behaviour
    for i,entry in ipairs(self.aspects) do
        local aspect_args = self:extractAspectClassEntry(entry)
        local a = aspect_args.aspect(aspect_args.args)
        a:setActor(self)
        a:setup()
        -- run any callbacks for this aspect type
        if on_setup_cb and on_setup_cb[a.TYPE] then
            on_setup_cb[a.TYPE](a)
        end
        -- store aspect in the type table
        self.aspects_by_type[a.TYPE] = a
        table.insert( self.aspect_instances, a )
        ASPECT_MANAGER:registerAspect(a)
    end
end

function Actor:postInitializeAspects()
    for i, aspect in ipairs(self.aspect_instances) do
        aspect:postSetup()
    end
end

function Actor:extractAspectClassEntry( aspect_class_entry )
    -- extract the aspect class and args from an entry
    -- (from self.aspects)
    if aspect_class_entry.TYPE ~= nil then
        return { aspect=aspect_class_entry, args={} }
    else
        return {
            aspect=aspect_class_entry[1],
            args=aspect_class_entry[2]
        }
    end
end

function Actor:getAspect( aspect )
    local typename = aspect.TYPE or aspect
    return self.aspects_by_type[typename]
end

function Actor:getAspectClass( aspect_class )
    -- return the matching aspect class and the args
    -- supplied to the constructor
    for i,aklass in ipairs(self.aspects) do
        local aspect_args = self:extractAspectClassEntry( aklass )
        assert( aspect_args.aspect ~= nil)
        if aspect_args.aspect.TYPE == aspect_class.TYPE then
            return aspect_args
        end
    end
    return nil
end

-- I need a container which manages the instances of actors.
-- Creation of actors should be done from this manager too, in order
-- to ease changes made during actor construction
ActorManager = class()

function ActorManager:__init()
    self.actors = {} -- a set of actor instances. name -> reference
    self.actors_by_name = {} -- name -> list of
    self.count = 0 -- TODO: have to decrease this on gc
end

function ActorManager:create( actor_class, on_setup_cb )
    -- create a new actor instance based on the class
    local actor = actor_class()
    actor.uuid  = self:createUniqueName( actor_class )
    -- initialize all connected aspects
    actor:initializeAspects(on_setup_cb)
    -- and now process any post setup things for the aspects
    -- TODO: maybe we don't need this after all
    actor:postInitializeAspects()
    if f then
        f(actor)
    end
    self.actors[actor.uuid] = actor
    assert( self.actors_by_name[ actor.name ] ~= nil )
    table.insert( self.actors_by_name[ actor.name ], actor )
    self.count = self.count + 1
    return actor
end

function ActorManager:update()
    -- iterate over all actors, iterate over the
    -- aspect instances in correct order (the sequence
    -- is defined by the order the aspect classes are entered
    -- by the user)
    for uuid,actor in pairs(self.actors) do
        for i,aspect in ipairs(actor.aspect_instances) do
            aspect:update()
        end
    end
end

function ActorManager:count()
    return self.count
end

function ActorManager:ensureActorListByNameExists( actorname )
    if not self.actors_by_name[ actorname ] then
        self.actors_by_name[ actorname ] = {}
    end
    return self.actors_by_name[ actorname ]
end

function ActorManager:createUniqueName( actor_class )
    local actorlist = self:ensureActorListByNameExists( actor_class.name )
    local count = table.getn( actorlist )
    if count ~= nil then
        return actor_class.name .. count
    end
    return actor_class.name .. 0
end

ACTOR_MANAGER = ActorManager()
