#include "main.h"
#include "lua_game.h"

#include <lua.hpp>

#include <string>
#include <iostream>

void pushTableKeyNil(lua_State *L, const char *key) {
    // assumes a table in -1 of the stack
    lua_pushstring(L, key);
    lua_pushnil(L);
    lua_settable(L, -3);
}

static const luaL_reg lua_game_lib[] = {
    {NULL, NULL}
};

//----
// App Binding
//----
static int lua_game_add_entity(lua_State *L) {
    const char *name     = luaL_checkstring(L, 1);
    const char *filename = luaL_checkstring(L, 2);
    const char *nodename = luaL_checkstring(L, 3);
    int x                = luaL_checknumber(L, 4);
    int y                = luaL_checknumber(L, 5);
    int z                = luaL_checknumber(L, 6);
    Ogre::SceneNode *node = APP->addEntity(name, filename, nodename, x, y, z);
    script_binder_pushusertype_nogc(SCRIPT, node, "node");
    return 1;
}

static const luaL_reg lua_app_lib[] = {
    {"add_entity", lua_game_add_entity},
    {NULL, NULL}
};

//----
// Node Binding
//----

static int lua_node_hello(lua_State *L) {
    Ogre::SceneNode *node = (Ogre::SceneNode*)script_binder_checkusertype_nogc(SCRIPT, 1, "node");
    std::cout << "SceneNode update: " << node->getName() << std::endl;
    return 0;
}

static int lua_node_destroy(lua_State *L) {
    void *udata = script_binder_checkusertype_nogc(SCRIPT, 1, "node");
    script_binder_releaseusertype(SCRIPT, udata);
    Ogre::SceneNode *node = (Ogre::SceneNode*)udata;
    delete node;
    return 0;
}

static int lua_node_getattachedobject(lua_State *L) {
    Ogre::SceneNode *node = (Ogre::SceneNode*)script_binder_checkusertype_nogc(SCRIPT, 1, "node");
    if (lua_isnumber(L, 2)) {
        Ogre::Entity *entity = (Ogre::Entity*) node->getAttachedObject(luaL_checknumber(L, 2));
        script_binder_pushusertype_nogc(SCRIPT, entity, "entity");
    } else {
        Ogre::Entity *entity = (Ogre::Entity*) node->getAttachedObject(luaL_checkstring(L, 2));
        script_binder_pushusertype_nogc(SCRIPT, entity, "entity");
    }
    return 1;
}

static int lua_node_setscale( lua_State *L ) {
    std::cout << "SET SCALE BEGIN" << std::endl;
    Ogre::SceneNode *node = (Ogre::SceneNode*) script_binder_checkusertype_nogc(SCRIPT, 1, "node");
    std::cout << "SET SCALE stage 2" << std::endl;
    node->setScale(
            luaL_checknumber(L, 2),
            luaL_checknumber(L, 3),
            luaL_checknumber(L, 4)
            );
    return 0;
}

static int lua_node_getposition( lua_State *L ) {
    int idx = 0;
    if (lua_isthread(L,1)) {
        std::cout << "WE HAVE A MOFO THREAD" << std::endl;
        idx += 1;
    }
    std::cout << "STACK SIZE: " << script_stack_size(SCRIPT) << std::endl;
    std::cout << "START GET POSITION" << std::endl;
    Ogre::SceneNode *node = (Ogre::SceneNode*) script_binder_checkusertype_nogc(SCRIPT, idx+1, "node");
    std::cout << "GOT NODE" << std::endl;
    Ogre::Vector3 pos = node->getPosition();
    std::cout << "GOT POSITION: " << pos.x << ":" << pos.y << ":" << pos.z << std::endl;
    lua_pushnumber(L, pos.x);
    lua_pushnumber(L, pos.y);
    lua_pushnumber(L, pos.z);
    return 3;
}

static int lua_node_setdirection( lua_State *L ) {
    Ogre::SceneNode *node = (Ogre::SceneNode*) script_binder_checkusertype_nogc(SCRIPT, 1, "node");
    node->setDirection(
            Ogre::Vector3(
                luaL_checknumber(L, 2),
                luaL_checknumber(L, 3),
                luaL_checknumber(L, 4)
            ));
    return 0;
}

static int lua_node_translate( lua_State *L ) {
    Ogre::SceneNode *node = (Ogre::SceneNode*) script_binder_checkusertype_nogc(SCRIPT, 1, "node");
    node->translate(
            luaL_checknumber(L, 2),
            luaL_checknumber(L, 3),
            luaL_checknumber(L, 4)
        );
    return 0;
}

static const luaL_reg lua_node_lib[] = {
    {"hello", lua_node_hello},
    {"getAttachedObject", lua_node_getattachedobject},
    {"setScale", lua_node_setscale},
    {"getPosition", lua_node_getposition},
    {"setDirection", lua_node_setdirection},
    {"translate", lua_node_translate},
    {NULL, NULL}
};

//----
// Entity Binding
//----
static int lua_entity_destroy( lua_State *L ) {
    void *udata = script_binder_checkusertype_nogc(SCRIPT, 1, "entity");
    script_binder_releaseusertype(SCRIPT, udata);
    Ogre::Entity *entity = (Ogre::Entity*) udata;
    std::cout << "called destroy for entity " << entity->getName() << std::endl;
    delete entity;
    return 0;
}

static int lua_entity_setmaterialname( lua_State *L ) {
    Ogre::Entity *entity = (Ogre::Entity*) script_binder_checkusertype_nogc(SCRIPT, 1, "entity");
    entity->setMaterialName(luaL_checkstring(L,2));
    return 0;
}

static const luaL_reg lua_entity_lib[] = {
    {"setMaterialName", lua_entity_setmaterialname},
    {NULL, NULL}
};

int luaopen_game(lua_State *L) {
    luaL_register(L, "game", lua_game_lib);

    //pushTableKeyNil(L, "on_keydown");
    //pushTableKeyNil(L, "on_keyup");
    pushTableKeyNil(L, "on_mousedown");
    pushTableKeyNil(L, "on_mouseup");

    // create a table called UNCOLLECTABLES
    lua_pushstring(L, "UNCOLLECTABLES");
    lua_newtable(L);
    lua_settable(L, -3);

    lua_pushstring(L, "UNCOLLECTABLES");
    lua_gettable(L, -2);
    lua_ref(L, LUA_REGISTRYINDEX);

    printf("STACK SIZE:%d", script_stack_size(SCRIPT));

    // game table at -1

    // game (-3), app (-2), new table (-1)
    lua_pushstring(L, "app");
    lua_newtable(L);
    luaL_register(L, NULL, lua_app_lib);

    pushTableKeyNil(L, "on_scenesetup");

    lua_settable(L, -3);
    lua_pop(L, 1);

    // bind the Ogre Entity/SceneNode Object
    script_binder_init(SCRIPT, "node",   lua_node_lib,   lua_node_destroy);
    script_binder_init(SCRIPT, "entity", lua_entity_lib, lua_entity_destroy);

    return 0;
}
