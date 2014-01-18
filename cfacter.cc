#include "cfacterlib.h"

#include <iostream>

using namespace std;

int main(int argc, char **argv)
{
    loadfacts();
    
    #define MAX_LEN_FACTS_JSON_STRING (1024 * 1024)  // go crazy here
    char facts_json[MAX_LEN_FACTS_JSON_STRING];
    if (to_json(facts_json, MAX_LEN_FACTS_JSON_STRING) < 0) {
	cout << "Wow, that's a lot of facts" << endl;
        exit(1);
    }
    cout << facts_json << endl;
}    
