Native Facter
=============

An implementation of facter functionality in C++11, providing:
* a shared library which gather facts about the system
* an executable for standalone command line usage
* a gem with a facter-like interface, for use in ruby applications

Build Requirements
------------------

* GCC 4.8+ or Clang 5.0+ (OSX)
* CMake >= 2.8.12
* Boost C++ Libraries >= 1.54
* yaml-cpp >= 0.5.1

Optional Build Libraries
------------------------

* OpenSSL >= 1.0.1.g - enables SSH fingerprinting facts.
* libblkid (Linux only) - enables the partitions fact.
* libcurl >= 7.18.0 - enables facts that perform HTTP requests.

Initial Setup
-------------

### Setup on Fedora 20

The following will install all required tools and libraries:

    yum install cmake boost-devel openssl-devel yaml-cpp-devel libblkid-devel libcurl-devel gcc-c++ make

### Setup on Mac OSX Mavericks (homebrew)

This assumes Clang is installed and the system OpenSSL libraries will be used.

The following will install all required libraries:

    brew install cmake boost yaml-cpp

### Setup on Ubuntu 14.04 (Trusty)

The following will install most required tools and libraries:

    apt-get install build-essential cmake libboost-all-dev libssl-dev libyaml-cpp-dev libblkid-dev libcurl4-openssl-dev

### Setup on Windows

MinGW-w64 is used for full C++11 support, and Chocolatey to install some tools. You should have at least 2GB of memory.

*   install CMake - http://www.cmake.org/download/, choose the option to add it to the system PATH
*   install MinGW-w64 - http://sourceforge.net/projects/mingw-w64/files/latest/download, recommended settings: 4.8.2, posix, seh/dwarf

For the remaining tasks, build commands can be executed in the shell from Start > MinGW-w64 project > Run Terminal

*   build Boost - http://sourceforge.net/projects/boost/files/latest/download

        .\bootstrap mingw
        .\b2 toolset=gcc --build-type=minimal install --prefix=<boost install path> --with-program_options --with-system --with-filesystem --with-date_time --with-thread --with-regex --with-log

*   build yaml-cpp - https://code.google.com/p/yaml-cpp/downloads

        mkdir build && cd build
        cmake -G "MinGW Makefiles" -DBOOST_INCLUDEDIR=<boost install path>\include\boost-<version> -DCMAKE_INSTALL_PREFIX=<yamlcpp install path>
        mingw32-make install

Note that OpenSSL, libblkid, and libcurl aren't needed on Windows. More detailed notes are available in WINDOWS.md.


Pre-Build
---------

All of the following examples start by assuming the current directory is the root of the repo.

On Windows, add `-G "MinGW Makefiles" -DBOOST_ROOT=\<boost install path\> -DYAMLCPP_ROOT=\<yamlcpp install path\> -DBOOST_STATIC=ON` to the `cmake` invocation. You may have to explicily specify BOOST_INCLUDEDIR or BOOST_LIBRARYDIR.

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

`$ release/bin/cfacter`

For a debug build:

`$ debug/bin/cfacter`

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

Here's a simple example of using the C++11 API to output all facts as YAML.

    #include <facter/facts/collection.hpp>
    #include <facter/logging/logging.hpp>
    #include <iostream>

    using namespace std;
    using namespace facter::facts;
    using namespace facter::logging;

    int main()
    {
        // Setup logging to cout
        setup_logging(cout);

        // Override the default log level (warning) with the info level
        set_level(log_level::info);

        // Create a fact collection and write the collection out
        collection facts;
        facts.add_default_facts();
        facts.add_external_facts();
        facts.write(cout, format::yaml);
        cout << endl;
    }

To build the above, link with libfacter:

    $ g++ example.cc -o myfacter -std=c++11 -lfacter
    $ ./myfacter
