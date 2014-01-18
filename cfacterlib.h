#ifndef __CFACTERLIB_IMPL_H__
#define __CFACTERLIB_IMPL_H__

#include <stdlib.h>

extern "C" {

void clear();
void loadfacts();
int  to_json(char *facts, size_t facts_len);
int  value(const char *fact, char *value, size_t value_len);
void search_external(const char *dirs);

}

#endif
