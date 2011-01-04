#include "main.h"
#include "lua_game.h"

#include <lua.hpp>

void pushTableKeyNil(lua_State *L, const char *key) {
    // assumes a table in -1 of the stack
    lua_pushstring(L, key);
    lua_pushnil(L);
    lua_settable(L, -3);
}

static int lua_game_add_entity(lua_State *L) {
    const char *name     = luaL_checkstring(L, 1);
    const char *filename = luaL_checkstring(L, 2);
    const char *nodename = luaL_checkstring(L, 3);
    int x                = luaL_checknumber(L, 4);
    int y                = luaL_checknumber(L, 5);
    int z                = luaL_checknumber(L, 6);
    APP->addEntity(name, filename, nodename, x, y, z);
    return 0;
}

static const luaL_reg lua_game_lib[] = {
    {NULL, NULL}
};

static const luaL_reg lua_app_lib[] = {
    {"add_entity", lua_game_add_entity},
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

    return 0;
}
