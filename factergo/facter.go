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
#cgo LDFLAGS: -fPIC -Wl,-Bstatic -L/opt/puppetlabs/puppet/lib/ -lfacter -laugeas -lcpp-hocon -l:leatherman_execution.a -l:leatherman_logging.a -l:leatherman_locale.a -l:leatherman_ruby.a -l:leatherman_dynamic_library.a -l:leatherman_util.a -l:leatherman_file_util.a -l:leatherman_curl.a -L /opt/pl-build-tools/lib/ -lyaml-cpp -l:libboost_log.a -l:libboost_log_setup.a -l:libboost_thread.a -l:libboost_date_time.a -l:libboost_filesystem.a -l:libboost_system.a -l:libboost_chrono.a -l:libboost_regex.a -l:libboost_atomic.a -l:libboost_program_options.a -l:libboost_locale.a -lcurl -lblkid -luuid -lssl -lcrypto -lz -lstdc++ -Wl,-Bdynamic -lrt -ldl -lm
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
