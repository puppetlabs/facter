#include <catch.hpp>
#include <facter/util/string.hpp>

using namespace std;
using namespace facter::util;

SCENARIO("converting bytes to hex strings") {
    uint8_t buffer[] = { 0xBA, 0xAD, 0xF0, 0x0D };
    WHEN("specifying uppercase") {
        THEN("hex characters should be uppercase") {
            REQUIRE(to_hex(buffer, sizeof(buffer), true) == "BAADF00D");
        }
    }
    WHEN("specifying the default lowercase") {
        THEN("hex characters should be lowercase") {
            REQUIRE(to_hex(buffer, sizeof(buffer)) == "baadf00d");
        }
    }
    GIVEN("a null buffer") {
        THEN("an empty string should be returned") {
            REQUIRE(to_hex(nullptr, 0) == "");
        }
    }
    GIVEN("an empty buffer") {
        THEN("an empty string should be returned") {
            REQUIRE(to_hex(buffer, 0) == "");
        }
    }
}

SCENARIO("converting bytes to SI unit strings") {
    GIVEN("zero bytes") {
        THEN("the string should show 0 bytes") {
            REQUIRE(si_string(0) == "0 bytes");
        }
    }
    GIVEN("less than 1 KiB") {
        WHEN("not close to 1 KiB") {
            THEN("the string should be in bytes") {
                REQUIRE(si_string(100) == "100 bytes");
            }
        }
        WHEN("close to 1 KiB") {
            THEN("the string should be in bytes") {
                REQUIRE(si_string(1023) == "1023 bytes");
            }
        }
    }
    GIVEN("exactly 1 KiB") {
        THEN("the string should be in KiB") {
            REQUIRE(si_string(1024) == "1.00 KiB");
        }
    }
    GIVEN("less than 1 MiB") {
        WHEN("not close to 1 MiB") {
            THEN("the string should be in KiB") {
                REQUIRE(si_string(4097) == "4.00 KiB");
            }
        }
        WHEN("almost 1 MiB") {
            THEN("the string should be in MiB") {
                REQUIRE(si_string((1024ull * 1024ull) - 1) == "1.00 MiB");
            }
        }
    }
    GIVEN("exactly 1 MiB") {
        THEN("the string should be in MiB") {
            REQUIRE(si_string(1024ull * 1024ull) == "1.00 MiB");
        }
    }
    GIVEN("less than 1 GiB") {
        WHEN("not close to 1 GiB") {
            THEN("the string should be in MiB") {
                REQUIRE(si_string(10ull * 1024ull * 1023ull) == "9.99 MiB");
            }
        }
        WHEN("almost 1 GiB") {
            THEN("the string should be in GiB") {
                REQUIRE(si_string((1024ull * 1024ull * 1024ull) - 1) == "1.00 GiB");
            }
        }
    }
    GIVEN("exactly 1 GiB") {
        THEN("the string should be in GiB") {
            REQUIRE(si_string(1024ull * 1024ull * 1024ull) == "1.00 GiB");
        }
    }
    GIVEN("less than 1 TiB") {
        WHEN("not close to 1 TiB") {
            THEN("the string should be in GiB") {
                REQUIRE(si_string(12ull * 1024ull * 1024ull * 1023ull) == "11.99 GiB");
            }
        }
        WHEN("almost 1 TiB") {
            THEN("the string should be in TiB") {
                REQUIRE(si_string((1024ull * 1024ull * 1024ull * 1024ull) - 1) == "1.00 TiB");
            }
        }
    }
    GIVEN("exactly 1 TiB") {
        THEN("the string should be in TiB") {
            REQUIRE(si_string(1024ull * 1024ull * 1024ull * 1024ull) == "1.00 TiB");
        }
    }
    GIVEN("less than 1 PiB") {
        WHEN("not close to 1 PiB") {
            THEN("the string should be in TiB") {
                REQUIRE(si_string(50ull * 1024ull * 1024ull * 1024ull * 1023ull) == "49.95 TiB");
            }
        }
        WHEN("almost 1 PiB") {
            THEN("the string should be in PiB") {
                REQUIRE(si_string((1024ull * 1024ull * 1024ull * 1024ull * 1024ull) - 1) == "1.00 PiB");
            }
        }
    }
    GIVEN("exactly 1 PiB") {
        THEN("the string should be in PiB") {
            REQUIRE(si_string(1024ull * 1024ull * 1024ull * 1024ull * 1024ull) == "1.00 PiB");
        }
    }
    GIVEN("less than 1 EiB") {
        WHEN("not close to 1 EiB") {
            THEN("the string should be in PiB") {
                REQUIRE(si_string(100ull * 1024ull * 1024ull * 1024ull * 1024ull * 1023ull) == "99.90 PiB");
            }
        }
        WHEN("almost 1 EiB") {
            THEN("the string should be in EiB") {
                REQUIRE(si_string((1024ull * 1024ull * 1024ull * 1024ull * 1024ull * 1024ull) - 1) == "1.00 EiB");
            }
        }
    }
    GIVEN("exactly 1 EiB") {
        THEN("the string should be in PiB") {
            REQUIRE(si_string(1024ull * 1024ull * 1024ull * 1024ull * 1024ull * 1024ull) == "1.00 EiB");
        }
    }
    GIVEN("the unsigned maximum 64-bit value") {
        THEN("the string should be in EiB") {
            REQUIRE(si_string(numeric_limits<uint64_t>::max()) == "16.00 EiB");
        }
    }
}

SCENARIO("converting percentages to strings") {
    GIVEN("any value out of zero") {
        THEN("it should be 100%") {
            REQUIRE(percentage(0, 0) == "100%");
            REQUIRE(percentage(10000, 0) == "100%");
        }
    }
    GIVEN("zero out of any value") {
        THEN("it should be 0%") {
            REQUIRE(percentage(0, 10) == "0%");
            REQUIRE(percentage(0, 100) == "0%");
        }
    }
    GIVEN("more than the maximum") {
        THEN("it should be 100%") {
            REQUIRE(percentage(1000, 100) == "100%");
        }
    }
    GIVEN("small percentages") {
        THEN("it should round to the nearest hundred of a percent") {
            REQUIRE(percentage(1, 100) == "1.00%");
            REQUIRE(percentage(11, 1000) == "1.10%");
            REQUIRE(percentage(111, 10000) == "1.11%");
            REQUIRE(percentage(1140000000ul, 50000000000ul) == "2.28%");
            REQUIRE(percentage(1000, 10000) == "10.00%");
        }
    }
    GIVEN("large percentages") {
        THEN("it should round to the nearest hundred of a percent, but never 100%") {
            REQUIRE(percentage(414906340801ul, 560007030104ul) == "74.09%");
            REQUIRE(percentage(99984, 100000) == "99.98%");
            REQUIRE(percentage(999899, 1000000) == "99.99%");
            REQUIRE(percentage(99999, 100000) == "99.99%");
        }
    }
    GIVEN("the maximum value") {
        WHEN("off by one") {
            THEN("it should not be 100%") {
                REQUIRE(percentage(numeric_limits<uint64_t>::max() - 1, numeric_limits<uint64_t>::max()) == "99.99%");
            }
        }
        WHEN("both are maximum") {
            THEN("it should be 100%") {
                REQUIRE(percentage(numeric_limits<uint64_t>::max(), numeric_limits<uint64_t>::max()) == "100%");
            }
        }
    }
}

SCENARIO("converting frequencies to strings") {
    GIVEN("a frequency of 0") {
        THEN("it should report in Hz") {
            REQUIRE(frequency(0) == "0 Hz");
        }
    }
    GIVEN("a frequency of less than 1 kHz") {
        WHEN("not close to 1 kHz") {
            THEN("it should be in Hz") {
                REQUIRE(frequency(100) == "100 Hz");
            }
        }
        WHEN("close to 1 kHz") {
            THEN("it should be in Hz") {
                REQUIRE(frequency(999) == "999 Hz");
            }
        }
    }
    GIVEN("exactly 1 kHz") {
        THEN("it should be in kHz") {
            REQUIRE(frequency(1000) == "1.00 kHz");
        }
    }
    GIVEN("a frequency of less than 1 MHz") {
        WHEN("not close to 1 MHz") {
            THEN("it should be in kHz") {
                REQUIRE(frequency(1000 * 999) == "999.00 kHz");
            }
        }
        WHEN("close to 1 MHz") {
            THEN("it should be in MHz") {
                REQUIRE(frequency((1000 * 1000) - 1) == "1.00 MHz");
            }
        }
    }
    GIVEN("exactly 1 MHz") {
        THEN("it should be in MHz") {
            REQUIRE(frequency(1000 * 1000) == "1.00 MHz");
        }
    }
    GIVEN("a frequency of less than 1 GHz") {
        WHEN("not close to 1 GHz") {
            THEN("it should be in MHz") {
                REQUIRE(frequency(1000 * 1000 * 999) == "999.00 MHz");
            }
        }
        WHEN("close to 1 GHz") {
            THEN("it should be in GHz") {
                REQUIRE(frequency((1000 * 1000 * 1000) - 1) == "1.00 GHz");
            }
        }
    }
    GIVEN("exactly 1 GHz") {
        THEN("it should be in GHz") {
            REQUIRE(frequency(1000 * 1000 * 1000) == "1.00 GHz");
        }
    }
    GIVEN("a frequency of less than 1 THz") {
        WHEN("not close to 1 THz") {
            THEN("it should be in GHz") {
                REQUIRE(frequency(1000ull * 1000 * 1000 * 999) == "999.00 GHz");
            }
        }
        WHEN("close to 1 THz") {
            THEN("it should be in THz") {
                REQUIRE(frequency((1000ull * 1000 * 1000 * 1000) - 1) == "1.00 THz");
            }
        }
    }
    GIVEN("exactly 1 THz") {
        THEN("it should be in THz") {
            REQUIRE(frequency(1000ull * 1000 * 1000 * 1000) == "1.00 THz");
        }
    }
    GIVEN("the maximum value") {
        THEN("it should be in Hz") {
            REQUIRE(frequency(numeric_limits<int64_t>::max()) == "9223372036854775807 Hz");
        }
    }
}

SCENARIO("converting strings to integers") {
    GIVEN("a string that is a valid integer") {
        THEN("it should be converted to its integer representation") {
            auto oint = maybe_stoi("12");
            REQUIRE(oint.is_initialized());
            REQUIRE(oint.get_value_or(0) == 12);
        }
    }
    GIVEN("a string that is not a valid integer") {
        THEN("nothing should be returned") {
            REQUIRE_FALSE(maybe_stoi("foo").is_initialized());
        }
    }
}
