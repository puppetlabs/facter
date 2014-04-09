#ifndef __CFACTERLIB_H__
#define __CFACTERLIB_H__

#include <stdlib.h>

extern "C" {

    void clear();
    int to_json(char *facts, size_t facts_len);
    int get_value(const char *fact, char *value, size_t value_len);
    void search_external(const char *dirs);

}

#endif
