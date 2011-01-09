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

static int lua_game_add_line(lua_State *L) {
    const char *name = luaL_checkstring(L, 1);
    Ogre::ManualObject *obj = APP->addLine(name);
    script_binder_pushusertype_nogc(SCRIPT, obj, "manualobject");
    return 1;
}

static const luaL_reg lua_app_lib[] = {
    {"add_entity", lua_game_add_entity},
    {"add_line", lua_game_add_line},
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
    Ogre::SceneNode *node = (Ogre::SceneNode*) script_binder_checkusertype_nogc(SCRIPT, 1, "node");
    node->setScale(
            luaL_checknumber(L, 2),
            luaL_checknumber(L, 3),
            luaL_checknumber(L, 4)
            );
    return 0;
}

static int lua_node_getposition( lua_State *L ) {
    Ogre::SceneNode *node = (Ogre::SceneNode*) script_binder_checkusertype_nogc(SCRIPT, 1, "node");
    Ogre::Vector3 pos = node->getPosition();
    lua_pushnumber(L, pos.x);
    lua_pushnumber(L, pos.y);
    lua_pushnumber(L, pos.z);
    return 3;
}

static int lua_node_lookat( lua_State *L ) {
    Ogre::SceneNode *self = (Ogre::SceneNode*) script_binder_checkusertype_nogc(SCRIPT, 1, "node");
    self->lookAt(
            Ogre::Vector3(
                luaL_checknumber(L, 2),
                luaL_checknumber(L, 3),
                luaL_checknumber(L, 4)
            ),
            Ogre::Node::TS_WORLD,
            Vector3::UNIT_Z
            );
    return 0;
}

static int lua_node_setautotracking( lua_State *L ) {
    Ogre::SceneNode *self = (Ogre::SceneNode*) script_binder_checkusertype_nogc(SCRIPT, 1, "node");
    bool enabled = lua_toboolean(L, 2);
    Ogre::SceneNode *target = (Ogre::SceneNode*) script_binder_checkusertype_nogc(SCRIPT, 3, "node");
    self->setAutoTracking( enabled, target, Vector3::UNIT_Z );
    return 0;
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
    {"setAutoTracking", lua_node_setautotracking},
    {"lookAt", lua_node_lookat},
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
    //std::cout << "called destroy for entity " << entity->getName() << std::endl;
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

//----
// ManualObject Binding
//----
static int lua_manualobject_destroy( lua_State *L ) {
    void *udata = script_binder_checkusertype_nogc(SCRIPT, 1, "manualobject");
    script_binder_releaseusertype(SCRIPT, udata);
    ManualObject *obj = (ManualObject*) udata;
    //std::cout << "called destroy for entity " << entity->getName() << std::endl;
    delete obj;
    return 0;
}
static int lua_manualobject_clear( lua_State *L ) {
    ManualObject *obj = (ManualObject*)script_binder_checkusertype_nogc(SCRIPT, 1, "manualobject");
    obj->clear();
    return 0;
}

static int lua_manualobject_begin( lua_State *L ) {
    ManualObject *obj = (ManualObject*)script_binder_checkusertype_nogc(SCRIPT, 1, "manualobject");
    obj->begin( luaL_checkstring(L, 2) , Ogre::RenderOperation::OT_LINE_STRIP );
    return 0;
}

static int lua_manualobject_position( lua_State *L ) {
    ManualObject *obj = (ManualObject*)script_binder_checkusertype_nogc(SCRIPT, 1, "manualobject");
    obj->position(
            luaL_checknumber(L, 2),
            luaL_checknumber(L, 3),
            luaL_checknumber(L, 4)
            );
    return 0;
}

static int lua_manualobject_end( lua_State *L ) {
    ManualObject *obj = (ManualObject*)script_binder_checkusertype_nogc(SCRIPT, 1, "manualobject");
    obj->end();
    return 0;
}

static const luaL_reg lua_manaulobject_lib[] = {
    {"destroy", lua_manualobject_destroy},
    {"clear",   lua_manualobject_clear},
    {"begin",   lua_manualobject_begin},
    {"position", lua_manualobject_position},
    {"finish",      lua_manualobject_end},
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
    script_binder_init(SCRIPT, "manualobject", lua_manaulobject_lib, lua_manualobject_destroy);

    return 0;
}
