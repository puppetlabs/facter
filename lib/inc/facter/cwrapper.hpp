#pragma once

#include "stdint.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Collects all default facts and store them as a C-string in JSON format. 
 * @param result a pointer to the C-string pointer to the collected facts.
 * @return Returns EXIT_FAILURE if it fails to retrieve or copy facts; EXIT_SUCCESS otherwise.
 */
uint8_t get_default_facts(char **result);

#ifdef __cplusplus
}
#endif
