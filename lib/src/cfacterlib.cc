#include <cfacterlib.h>

#include "rapidjson/document.h"
#include "rapidjson/prettywriter.h"
#include "rapidjson/stringbuffer.h"

#include <facts/fact_map.hpp>

using namespace std;
using namespace cfacter::facts;

int to_json(char *facts_json, size_t facts_len)
{
    // TODO: re-implement this with support for structured facts
    strncpy(facts_json, "", facts_len);
    return 0;
}

int get_value(const char *fact, char *value, size_t value_len)
{
    // TODO: reimplement this with support for structured facts
    strncpy(value, "", value_len);
    return 0;
}

void search_external(const char *dirs)
{
    // TODO
}
