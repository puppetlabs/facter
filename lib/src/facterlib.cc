#include <facter/facterlib.h>
#include <facter/facts/fact_map.hpp>

#include "rapidjson/document.h"
#include "rapidjson/prettywriter.h"
#include "rapidjson/stringbuffer.h"


using namespace std;
using namespace facter::facts;

void loadfacts()
{
    // This is a no-op of the fact map
}

int to_json(char *facts_json, size_t facts_len)
{
    // TODO: re-implement this with support for structured facts
    strncpy(facts_json, "", facts_len);
    return 0;
}

int value(const char *fact, char *value, size_t value_len)
{
    // TODO: reimplement this with support for structured facts
    strncpy(value, "", value_len);
    return 0;
}

void search_external(const char *dirs)
{
    // TODO
}
