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
    script_binder_pushusertype(SCRIPT, node, "node");
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
    Ogre::SceneNode *node = (Ogre::SceneNode*)script_binder_checkusertype(SCRIPT, 1, "node");
    std::cout << "SceneNode update: " << node->getName() << std::endl;
    return 0;
}

static int lua_node_destroy(lua_State *L) {
    Ogre::SceneNode *node = (Ogre::SceneNode*)script_binder_checkusertype(SCRIPT, 1, "node");
    delete node;
    return 0;
}

static int lua_node_getattachedobject(lua_State *L) {
    Ogre::SceneNode *node = (Ogre::SceneNode*)script_binder_checkusertype(SCRIPT, 1, "node");
    if (lua_isnumber(L, 2)) {
        Ogre::Entity *entity = (Ogre::Entity*) node->getAttachedObject(luaL_checknumber(L, 2));
        script_binder_pushusertype(SCRIPT, entity, "entity");
    } else {
        Ogre::Entity *entity = (Ogre::Entity*) node->getAttachedObject(luaL_checkstring(L, 2));
        script_binder_pushusertype(SCRIPT, entity, "entity");
    }
    return 1;
}

static int lua_node_setscale( lua_State *L ) {
    Ogre::SceneNode *entity = (Ogre::SceneNode*) script_binder_checkusertype(SCRIPT, 1, "node");
    entity->setScale(
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
    {NULL, NULL}
};

//----
// Entity Binding
//----
static int lua_entity_destroy( lua_State *L ) {
    Ogre::Entity *entity = (Ogre::Entity*) script_binder_checkusertype(SCRIPT, 1, "entity");
    delete entity;
    return 0;
}

static int lua_entity_setmaterialname( lua_State *L ) {
    Ogre::Entity *entity = (Ogre::Entity*) script_binder_checkusertype(SCRIPT, 1, "entity");
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
