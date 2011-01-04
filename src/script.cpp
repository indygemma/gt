#include "script.h"

#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "lua_game.h"

script_t *script_new() {
    script_t *script = new script_t();

    script->L = lua_open();
    luaL_openlibs(script->L);
    luaopen_game(script->L);

    lua_settop(script->L, 0); // clear the stack

    return script;
}

void script_error(script_t *script, const char *fmt, ...) {
    va_list argp;
    va_start(argp, fmt);
    vfprintf(stderr, fmt, argp);
    va_end(argp);
    lua_close(script->L);
    exit(EXIT_FAILURE);
}

void script_free(script_t *script) {
    lua_close(script->L);
}

int script_run(script_t *script, const char *filename) {
    if (luaL_dofile(script->L, filename) != 0)
        script_error(script, "error running '%s': %s", filename, lua_tostring(script->L, -1));
    return 0;
}

int script_eval(script_t *script, const char *buf, ...) {
    return luaL_dostring(script->L, buf);
}

int script_veval(script_t *script, const char *fmt, ...) {
    // TODO: support variable eval
    return 0;
}

int script_register_callback(script_t *script, char *name) {
    // example:
    //
    //   script_register_callback(s, "game.on_mouseclick"); <-- identifies on_mouseclick as function
    //   script_register_callback(s, "game.app.on_exit");   <-- on_exit is the callback
    //   script_register_callback(s, "on_quit");            <-- global callback
    //

    // identify the elements, separated by dots
    char *token = NULL;
    char *nexttoken = NULL;
    int count = 0;
    char *dup = strdup(name); // TODO: remove me if we're using C. no dup required in C
    nexttoken = strtok(dup, ".");
    while (nexttoken != NULL) {
        count++;
        token = nexttoken;
        nexttoken = strtok(NULL, ".");
        if (count == 1) {
            lua_getglobal(script->L, token);
            // no next token, we have a global callback
            if (nexttoken == NULL) break;
            // get the current token as table
        } else {
            // fetch the next
            lua_pushstring(script->L, token);
            lua_gettable(script->L, -2);
            // short circuit if there is a function on the stack
            if (lua_isfunction(script->L, -1)) break;
        }
    }
    // TODO: need more robust error handling
    // register the current token as callback
    int ref;
    if (lua_isfunction(script->L, -1)) {
        printf("registering '%s' of '%s' as callback\n", token, name);
        ref = luaL_ref(script->L, LUA_REGISTRYINDEX);
        script->callback_refs[name] = ref;
        count--; // ref apparently removes the element from the top stack
    } else {
        script_error(script, "%s is not a valid callback function", name);
    }
    // clean up the stack
    lua_pop(script->L, count);
    free(dup); // TODO: remove me if we're using C. no dup required in C
    return ref;
}

void script_pcallback(script_t *script, int cbid, int nargs, int nresult) {
    //printf("@call %d stack size: %d\n", cbid, script_stack_size(script));
    // NOTE: don't forget to pop the stack nresult times!
    //int ref = script->callback_refs[name];
    //printf("ref %d\n", ref);
    lua_rawgeti(script->L, LUA_REGISTRYINDEX, cbid);
    //printf("@after rawgeti %d stack size: %d\n", cbid, script_stack_size(script));
    //printf("top stack is function %d\n", lua_isfunction(script->L, -1));
    // now the function is on the top of the stack
    // move it down the stack nargs times so we have the correct stack composition
    //printf("shifting %d\n", -nargs-1);
    lua_insert(script->L, -nargs-1);
    //printf("is function at %d:%d\n", -nargs-1, lua_isfunction(script->L, -nargs-1));
    //printf("@before pcall %d stack size: %d\n", cbid, script_stack_size(script));
    if (lua_pcall( script->L, nargs, nresult, 0) != 0) {
        script_error(script, "Failed calling callback %d: %s\n", cbid, lua_tostring(script->L, -1));
    }
}

void script_vpcallback(script_t *script, char *name, const char *fmt, ...) {
    // TODO: implement vararg function call via callback registry
    // http://www.lua.org/pil/25.3.html
    int ref = script->callback_refs[name];
    printf("reference id for %s: %d\n", name, ref);
}

int script_stack_size(script_t *script) {
    return lua_gettop(script->L);
}

void script_stack_pop(script_t *script, int count) {
    lua_pop(script->L, count);
}
