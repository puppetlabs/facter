package facter

/*
#cgo LDFLAGS: -L${SRCDIR}/../release/lib -lfacter -lstdc++ /usr/local/lib/leatherman_execution.a /usr/local/lib/leatherman_logging.a /usr/local/lib/leatherman_locale.a /usr/local/lib/libboost_locale-mt.dylib /usr/local/lib/libboost_system-mt.dylib /usr/local/lib/libboost_log-mt.dylib /usr/local/lib/libboost_log_setup-mt.dylib /usr/local/lib/libboost_thread-mt.dylib /usr/local/lib/libboost_date_time-mt.dylib /usr/local/lib/libboost_filesystem-mt.dylib /usr/local/lib/libboost_chrono-mt.dylib /usr/local/lib/libboost_regex-mt.dylib /usr/local/lib/libboost_atomic-mt.dylib /usr/local/lib/leatherman_util.a /usr/local/lib/leatherman_file_util.a /usr/local/lib/libyaml-cpp.dylib /usr/local/lib/libboost_program_options-mt.dylib /usr/local/lib/libaugeas.dylib
#cgo CFLAGS: -I${SRCDIR}/../lib/inc

#include "facter/facts/cwrapper.hpp"
#include <stdlib.h>
*/
import "C"

import (
	"fmt"
	"unsafe"
)
func GetFacts() (string, error) {
	var resultC *C.char
	defer C.free(unsafe.Pointer(resultC))

	ec := C.get_facts(&resultC)
	if ec != 0 {
		return "", fmt.Errorf("Error thrown calling get_facts: %d", ec)
	}
	result := C.GoString(resultC)
	return result, nil
}
