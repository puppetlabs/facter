#ifndef LIB_INC_CFACTERLIB_H_
#define LIB_INC_CFACTERLIB_H_

#include <stdlib.h>

extern "C" {
    void clear();
    int to_json(char *facts, size_t facts_len);
    int get_value(const char *fact, char *value, size_t value_len);
    void search_external(const char *dirs);
}

#endif  // LIB_INC_CFACTERLIB_H_
