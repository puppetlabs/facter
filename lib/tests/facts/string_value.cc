#include <catch.hpp>
#include <facter/facts/scalar_value.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;
using namespace YAML;

SCENARIO("using a string fact value") {
    GIVEN("a value to copy") {
        string s = "hello world";
        string_value value(s);
        THEN("the value is copied") {
            REQUIRE(s == "hello world");
            REQUIRE(value.value() == "hello world");
        }
    }
    GIVEN("a value to move") {
        string s = "hello world";
        string_value value(std::move(s));
        THEN("the value is moved") {
            REQUIRE(s.empty());
            REQUIRE(value.value() == "hello world");
        }
    }

    GIVEN("a simple string value") {
        string_value value("foobar");
        WHEN("serialized to JSON") {
            THEN("it should have the same value") {
                json_value json;
                json_allocator allocator;
                value.to_json(allocator, json);
                REQUIRE(json.IsString());
                REQUIRE(json.GetString() == string("foobar"));
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should have the same value") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "foobar");
            }
        }
        WHEN("serialized to text with quotes") {
            THEN("it should be quoted") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "\"foobar\"");
                }
            }
        WHEN("serialized to text without quotes") {
            THEN("it should not be quoted") {
                ostringstream stream;
                value.write(stream, false);
                REQUIRE(stream.str() == "foobar");
            }
        }
    }

    GIVEN("an ipv6 address string value ending with ':'") {
        string_value value("fe80::");
        WHEN("serialized to JSON") {
            THEN("it should have the same value") {
                json_value json;
                json_allocator allocator;
                value.to_json(allocator, json);
                REQUIRE(json.IsString());
                REQUIRE(json.GetString() == string("fe80::"));
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should be quoted") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "\"fe80::\"");
            }
        }
        WHEN("serialized to text with quotes") {
            THEN("it should be quoted") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "\"fe80::\"");
                }
            }
        WHEN("serialized to text without quotes") {
            THEN("it should not be quoted") {
                ostringstream stream;
                value.write(stream, false);
                REQUIRE(stream.str() == "fe80::");
            }
        }
    }

    GIVEN("an ipv4 address string value") {
        string_value value("127.254.3.0");
        WHEN("serialized to JSON") {
            THEN("it should have the same value") {
                json_value json;
                json_allocator allocator;
                value.to_json(allocator, json);
                REQUIRE(json.IsString());
                REQUIRE(json.GetString() == string("127.254.3.0"));
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should have the same value") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "127.254.3.0");
            }
        }
        WHEN("serialized to text with quotes") {
            THEN("it should be quoted") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "\"127.254.3.0\"");
                }
            }
        WHEN("serialized to text without quotes") {
            THEN("it should not be quoted") {
                ostringstream stream;
                value.write(stream, false);
                REQUIRE(stream.str() == "127.254.3.0");
            }
        }
    }

    GIVEN("a ':' prefixed string value") {
        string_value value("::1");
        WHEN("serialized to JSON") {
            THEN("it should have the same value") {
                json_value json;
                json_allocator allocator;
                value.to_json(allocator, json);
                REQUIRE(json.IsString());
                REQUIRE(json.GetString() == string("::1"));
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should be quoted") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "\"::1\"");
            }
        }
        WHEN("serialized to text with quotes") {
            THEN("it should be quoted") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "\"::1\"");
                }
            }
        WHEN("serialized to text without quotes") {
            THEN("it should not be quoted") {
                ostringstream stream;
                value.write(stream, false);
                REQUIRE(stream.str() == "::1");
            }
        }
    }

    GIVEN("a valid mac address") {
        string_value value("00:50:56:55:42:45");
        WHEN("serialized to JSON") {
            THEN("it should have the same value") {
                json_value json;
                json_allocator allocator;
                value.to_json(allocator, json);
                REQUIRE(json.IsString());
                REQUIRE(json.GetString() == string("00:50:56:55:42:45"));
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should be quoted") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "\"00:50:56:55:42:45\"");
            }
        }
        WHEN("serialized to text with quotes") {
            THEN("it should be quoted") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "\"00:50:56:55:42:45\"");
                }
            }
        WHEN("serialized to text without quotes") {
            THEN("it should not be quoted") {
                ostringstream stream;
                value.write(stream, false);
                REQUIRE(stream.str() == "00:50:56:55:42:45");
            }
        }
    }

    GIVEN("a list of numbers") {
        string_value value("1,2,3,4,5");
        WHEN("serialized to JSON") {
            THEN("it should have the same value") {
                json_value json;
                json_allocator allocator;
                value.to_json(allocator, json);
                REQUIRE(json.IsString());
                REQUIRE(json.GetString() == string("1,2,3,4,5"));
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should be quoted") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "\"1,2,3,4,5\"");
            }
        }
        WHEN("serialized to text with quotes") {
            THEN("it should be quoted") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "\"1,2,3,4,5\"");
                }
            }
        WHEN("serialized to text without quotes") {
            THEN("it should not be quoted") {
                ostringstream stream;
                value.write(stream, false);
                REQUIRE(stream.str() == "1,2,3,4,5");
            }
        }
    }
}
