#include "script.h"

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <cstdarg>
#include <cstdio>
#include <cstdlib>

struct script_t {
    lua_State *L;
};

script_t *script_new() {
    script_t *script = new script_t();

    script->L = lua_open();
    luaL_openlibs(L);

    lua_settop(L, 0); // clear the stack

    return script;
}

void script_free(script_t *script) {
    
}
