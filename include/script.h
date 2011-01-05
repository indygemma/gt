#ifndef __SCRIPT_H__
#define __SCRIPT_H__

#include <lua.hpp>
#include <map>

struct script_t {
    lua_State *L;
    std::map<char*, int> callback_refs;
};

script_t *script_new();

void    script_bind(script_t *script);

void    script_error(script_t *script, const char *fmt, ...);
void    script_free(script_t *script);

int     script_run(script_t *script, const char *filename);
int     script_eval(script_t *script, const char *buf);
int     script_veval(script_t *script, const char *fmt, ...);

int     script_register_callback(script_t *script, char *name);
void    script_pcallback(script_t *script, int cbid, int nargs, int nresult);
void    script_vpcallback(script_t *script, int cbid, const char *fmt, ...);

int     script_stack_size(script_t *script);
void    script_stack_pop(script_t *script, int count);

//--- helper functions for binding

void    script_binder_init(script_t *script, const char *tname,
                                             const luaL_reg *flist,
                                             int (*destroy)(lua_State*));
void    script_binder_pushusertype(script_t *script, void *udata,
                                                     const char *tname);
void   *script_binder_checkusertype(script_t *script, int index,
                                                      const char *tname);
void    script_binder_releaseusertype(script_t *script, void *udata);
#endif
