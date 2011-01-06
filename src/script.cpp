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

    lua_settop(script->L, 0); // clear the stack

    return script;
}

// from lib_init.c
// call a c function in lua context. This is for example required
// in script_binder_init, where lua_replace(L, LUA_ENVIRONINDEX)
// causes a PANIC on runtime, when called from C.
void run_in_lua(script_t *script, int (*f)(lua_State*)) {
    lua_pushcfunction(script->L, f);
    //lua_pushstring(L, lib->name);
    lua_call(script->L, 0, 0);
}

void script_bind(script_t *script) {
    //luaopen_game(script->L);
    run_in_lua(script, luaopen_game);
    lua_settop(script->L, 0);
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

//--- helper functions for object binding
// source: Game Programming Gems 6 Page 347+
// Chapter "Binding C/C++ Objects to Lua"
//
// TODO: there is another method shown as the last alternative with
//       native tables. try that one out if the current approach
//       seems to become a bottleneck.

void script_binder_init(script_t *script, const char *tname,
                                             const luaL_reg *flist,
                                             int (*destroy)(lua_State*)) {
    lua_State *L = script->L;
    lua_newtable(L);                  // create table for uniqueness
    lua_pushstring(L, "v");
    lua_setfield(L, -2, "__mode");    // set as weak-value table
    lua_pushvalue(L, -1);             // duplicate table onto stack
    lua_setmetatable(L, -2);          // set itself as metatable
    lua_replace(L, LUA_ENVIRONINDEX); // set table as env table
    luaL_register(L, tname, flist);   // create libtable
    luaL_newmetatable(L, tname);      // create metatable for objects
    lua_pushvalue(L, -2);
    lua_setfield(L, -2, "__index");   // mt.__index = libtable
    lua_pushcfunction(L, destroy);
    lua_setfield(L, -2, "__gc");      // mt.__gc = destroy
    lua_pop(L, 1);                    // pop metatable
    // TODO: the stack is left with one item on top. what is it??
}

void script_binder_pushusertype(script_t *script, void *udata,
                                                     const char *tname) {
    lua_State *L = script->L;
    lua_pushlightuserdata(L,udata);
    lua_rawget(L, LUA_ENVIRONINDEX); // get udata in env table
    if (lua_isnil(L, -1)) {
        void ** ubox = (void**)lua_newuserdata(L,sizeof(void*));
        *ubox = udata;                  // store address in udata
        luaL_getmetatable(L,tname);     // get metatable
        lua_setmetatable(L, -2);        // set metatable for udata
        lua_pushlightuserdata(L,udata); // push address
        lua_pushvalue(L, -2);           // push udata
        lua_rawset(L,LUA_ENVIRONINDEX); // envtable[address] = udata
    }
}

void *script_binder_checkusertype(script_t *script, int index,
                                                      const char *tname) {
    //printf("CHECK USER TYPE start\n");
    void **udata = (void**)luaL_checkudata(script->L, index, tname);
    //printf("udata == 0: %d. %d\n", udata == 0, udata);
    if (udata == 0) {
        //printf("ERROR: UDATA IS EMPTY. tname = %s\n", tname);
        luaL_typerror(script->L,index,tname);
    }
    return *udata;
}

void script_binder_pushusertype_nogc(script_t *script, void *udata,
                                                         const char *tname) {
    lua_State *L = script->L;
    lua_pushlightuserdata(L, udata);
    lua_rawget(L, LUA_ENVIRONINDEX); // get object in env table
    if (lua_isnil(L, -1)) {
        lua_newtable(L);
        lua_pushlightuserdata(L, udata);
        lua_setfield(L,-2,"_pointer");
        luaL_getmetatable(L,tname);
        lua_setmetatable(L,-2);
        lua_pushlightuserdata(L, udata);
        lua_pushvalue(L,-2);
        lua_rawset(L,LUA_ENVIRONINDEX);
    }
}

void *script_binder_checkusertype_nogc(script_t *script, int index,
                                                        const char *tname) {
    lua_State *L = script->L;
    lua_getfield(L, LUA_REGISTRYINDEX, tname); // get type mt
    lua_getmetatable(L, index);                // get associated mt
    // notice: in the book there is inheritance support, we don't support it here
    while( lua_istable(L, -1) ) {
        if (lua_rawequal(L, -1, -2)) {
            lua_pop(L, 2);                      // pop string and mt
            lua_getfield(L, index, "_pointer");
            void *udata = lua_touserdata(L,-1);
            return udata;
        }
        lua_getfield(L,-1,"_base");
        lua_replace(L,-2);
    }
    luaL_typerror(L, index, tname);
    return NULL;
}

void script_binder_releaseusertype(script_t *script, void *udata) {
    lua_pushlightuserdata(script->L, udata);
    lua_pushnil(script->L);
    lua_settable(script->L, LUA_ENVIRONINDEX);
}
