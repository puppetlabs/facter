#pragma once
#include <facter/facts/collection.hpp>
#include <facter/facts/value.hpp>
#include <string>

bool load_custom_fact(std::string const& filename, facter::facts::collection& facts);

std::string ruby_value_to_string(facter::facts::value const* value);
