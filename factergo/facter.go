// +build linux,cgo

package factergo

// NB(ale): to install on Mac the expected static libiconv from source:
// - download from https://www.gnu.org/software/libiconv/#TOCdownloading
// - untar
// - ./configure --prefix=/usr/local --enable-static
// - edit include/iconv.h to define the LIBICONV_PLUG to some non null value
//   before it gets checked; that will ensure that the 'lib' prefix is not
//   appended to some symbols needed by Boost.Locale
// - make
// - make install

// NB(ale): getting few ld warnings (direct access) for Boost.Log (Boost v1.64)

/*
#cgo LDFLAGS: -fPIC -lfacter -laugeas -lcpp-hocon -lyaml-cpp -l:leatherman_execution.a -l:leatherman_logging.a -l:leatherman_locale.a -l:leatherman_ruby.a -l:leatherman_dynamic_library.a -l:leatherman_util.a -l:leatherman_file_util.a -l:leatherman_curl.a -L /opt/pl-build-tools/lib/ -lboost_log -lboost_log_setup -lboost_thread -lboost_date_time -lboost_filesystem -lboost_system -lboost_chrono -lboost_regex -lboost_atomic -lboost_program_options -lboost_locale -liconv -lcurl -lcrypto -ldl -lz -lstdc++ -lm
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
