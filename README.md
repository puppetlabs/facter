cfacter
=======

Tinkering with a C/C++ facter

Build Requirements
------------------

* CMake >= 2.8.12
* Boost C++ Libraries >= 1.48
* Apache log4cxx >= 10.0
* OpenSSL >= 1.0.1.g
* yaml-cpp >= 0.5.1
* Google's RE2 library

### Setup on Fedora 20

The following will pull all required tools and libraries in:

    yum install cmake boost-devel log4cxx-devel openssl-devel yaml-cpp-devel re2-devel

Pre-Build
---------

All of the following examples start by assuming the current directory is the root of the repo.

Before building cfacter, use `cmake` to generate build files:

    $ mkdir release
    $ cd release
    $ cmake ..

To generate build files with debug information:

    $ mkdir debug
    $ cd debug
    $ cmake -DCMAKE_BUILD_TYPE=Debug ..

Before building the gem, install the cfacter bundle:

    $ cd gem
    $ bundle install

Build
-----

To build cfacter, use 'make':

    $ cd release
    $ make

To build cfacter with debug information:

    $ cd debug
    $ make

To build the cfacter gem:

    $ cd gem
    $ rake gem

The gem will be created in the `gem/pkg` directory.

Run
---

You can run cfacter from where it was built:

`$ release/exe/cfacter`

For a debug build:

`$ debug/exe/cfacter`

Test
----

You can run cfacter tests using the test target:

    $ cd release
    $ make test

For a debug build:

    $ cd debug
    $ make test

For verbose test output, run `ctest` instead of using the test target:

    $ cd release
    $ ctest -V

To run gem tests:

    $ cd gem
    $ rspec

Install
-------

You can install cfacter into your system:

    $ cd release
    $ make && sudo make install

By default, cfacter will install files into `/usr/local/bin`, `/usr/local/lib`, and `/usr/local/include`.

To install to a different location, set the install prefix:

    $ cd release
    $ cmake -DCMAKE_INSTALL_PREFIX=~ ..
    $ make clean install

This would install cfacter into `~/bin`, `~/lib`, and `~/include`.

To install the gem (assumes gem is already built):

    $ cd gem
    $ gem install pkg/cfacter*.gem

Uninstall
---------

Run the following command to remove files that were previously installed:

    $ sudo xargs rm < release/install_manifest.txt

To uninstall the gem:

    $ gem uninstall cfacter

Documentation
-------------

To generate API documentation, install doxygen 1.8.7 or later.

    $ cd lib
    $ doxygen

To view the documentation, open `lib/html/index.html` in a web browser.


Using The C++11 API
-------------------

This section assumes that cfacter has been installed into the system.

Here's a simple example of using the C++11 API to output all facts.

    #include <facter/facts/fact_map.hpp>
    #include <iostream>

    using namespace std;
    using namespace facter::facts;

    int main() {
        fact_map facts;
        facts.resolve();
        facts.resolve_external();
        cout << facts << endl;
    }

To build the above, link with libfacter:

    $ g++ example.cc -o myfacter --std=c++11 -lfacter
    $ ./myfacter
