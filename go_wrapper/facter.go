package facter

// NB(ale): to install on Mac the expected static libiconv from source:
// - download from https://www.gnu.org/software/libiconv/#TOCdownloading
// - untar
// - ./configure --prefix=/usr/local --enable-static
// - edit include/iconv.h to define the LIBICONV_PLUG to some non null value
//   before it gets checked; that will ensure that the 'lib' prefix is not
//   appended to some symbols needed by Boost.Locale
// - make
// - make install

// NB(ale): getting a few ld warnings (direct access) for boost::log

/*
#cgo LDFLAGS: -fPIC -L${SRCDIR}/../release/lib -lstdc++ /usr/local/lib/libfacter.a /usr/local/lib/libaugeas.a /usr/local/lib/libcpp-hocon.a /usr/local/lib/libyaml-cpp.a /usr/local/lib/leatherman_execution.a /usr/local/lib/leatherman_logging.a /usr/local/lib/leatherman_locale.a /usr/local/lib/leatherman_ruby.a /usr/local/lib/leatherman_dynamic_library.a /usr/local/lib/leatherman_util.a /usr/local/lib/leatherman_file_util.a /usr/local/lib/libboost_system-mt.a /usr/local/lib/libboost_log-mt.a /usr/local/lib/libboost_log_setup-mt.a /usr/local/lib/libboost_thread-mt.a /usr/local/lib/libboost_date_time.a /usr/local/lib/libboost_filesystem-mt.a /usr/local/lib/libboost_chrono-mt.a /usr/local/lib/libboost_regex-mt.a /usr/local/lib/libboost_atomic-mt.a /usr/local/lib/libboost_program_options-mt.a /usr/local/lib/libboost_locale-mt.a /usr/local/lib/libiconv.a
#cgo CFLAGS: -I${SRCDIR}/../lib/inc

#include "facter/cwrapper.hpp"
#include <stdlib.h>
*/
import "C"

import (
	"fmt"
	"unsafe"
)

// GetFacts collects default facts as a C string in JSON format
func GetFacts() (string, error) {
	var resultC *C.char
	defer C.free(unsafe.Pointer(resultC))

	ec := C.get_default_facts(&resultC)
	if ec != 0 {
		return "", fmt.Errorf("Error thrown calling get_facts: %d", ec)
	}
	result := C.GoString(resultC)
	return result, nil
}
