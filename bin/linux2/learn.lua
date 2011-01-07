require "aspects/hunger"
require "aspects/map"

function dump(name, klass)
    print( name, klass, " klass._base: ", klass._base, " metatable: ", getmetatable(klass), " instance of ", klass._instanceof )
end

--dump( "Map2D          ", Map2D )
--dump( "Map2D Instance ", Map2D() )
--dump( "Hunger         ",  Hunger )
--dump( "Hunger Instance", Hunger() )

require "actors/sample"

local actors_map2d = ASPECT_MANAGER:getActorsWithAspectClass( Map2D )
local actors_mapitem = ASPECT_MANAGER:getActorsWithAspectClass( MapItem )

print( table.getn(actors_map2d) )
print( table.getn(actors_mapitem) )
table.foreach( actors_mapitem, function(k,v)
    print (k.name)
    print (v.aspect.TYPE)
    print (v.args.id)
end )

a1 = ACTOR_MANAGER:create(Level)
a2 = ACTOR_MANAGER:create(Level)
a3 = ACTOR_MANAGER:create(Animal)

print( Level )
print( "a1 Map2d instance: ", a1:getAspect(Map2D) )
print( "a2 Map2d instance: ", a2:getAspect(Map2D) )

--a1:getAspect(Map2D):setup()
