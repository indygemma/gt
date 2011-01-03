#ifndef __SCRIPT_H__
#define __SCRIPT_H__

struct script_t;

script_t *script_new();

void    script_error(script_t *script, const char *fmt, ...);
void    script_free(script_t *script);

#endif
