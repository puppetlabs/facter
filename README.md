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

Initial Setup
-------------

### Setup on Fedora 20

The following will install all required tools and libraries:

    yum install cmake boost-devel openssl-devel yaml-cpp-devel libblkid-devel gcc-c++ make

### Setup on Mac OSX Mavericks (homebrew)

This assumes Clang is installed and the system OpenSSL libraries will be used.

The following will install all required libraries:

    brew install cmake boost yaml-cpp

### Setup on Ubuntu 14.04 (Trusty)

The following will install most required tools and libraries:

    apt-get install build-essential cmake libboost-all-dev libssl-dev libyaml-cpp-dev libblkid-dev

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
        configure_logging(log_level::info, std::cout);

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
