Native Facter
=============

[![Linux Build Status](https://travis-ci.org/puppetlabs/cfacter.svg?branch=master)](https://travis-ci.org/puppetlabs/cfacter)
[![Windows Build Status](https://ci.appveyor.com/api/projects/status/5kltn836jkic167w/branch/master?svg=true)](https://ci.appveyor.com/project/MikaelSmith/cfacter-735/branch/master)
[![Unit Coverage Status](https://img.shields.io/coveralls/puppetlabs/cfacter.svg)](https://coveralls.io/r/puppetlabs/cfacter)

An implementation of facter functionality in C++11, providing:

* a shared library which gather facts about the system
* an executable for standalone command line usage
* a ruby file to enable `requre 'cfacter'`.

Please see our [extensibility document](https://github.com/puppetlabs/cfacter/blob/master/Extensibility.md) to learn more
about extending native facter using custom and external facts.

Build Requirements
------------------

* GCC 4.8+ or Clang 5.0+ (OSX)
* CMake >= 2.8.12
* Boost C++ Libraries >= 1.54
* yaml-cpp >= 0.5.1

Optional Build Libraries
------------------------

* OpenSSL - enables SSH fingerprinting facts.
* libblkid (Linux only) - enables the partitions fact.
* libcurl >= 7.18.0 - enables facts that perform HTTP requests.

Initial Setup
-------------

Note: Testing custom facts requires Ruby 1.9+ with libruby built as a dynamic library; that often implies development builds of Ruby.

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

[MinGW-w64](http://mingw-w64.sourceforge.net/) is used for full C++11 support, and [Chocolatey](https://chocolatey.org) can be used to install. You should have at least 2GB of memory for compilation.

* install [CMake](https://chocolatey.org/packages/cmake)
* install [MinGW-w64](https://chocolatey.org/packages/mingw)

        choco install mingw --params "/threads:win32"

For the remaining tasks, build commands can be executed in the shell from Start > MinGW-w64 project > Run Terminal

* select an install location for dependencies, such as C:\\tools or cmake\\release\\ext; we'll refer to it as $install

* build [Boost](http://sourceforge.net/projects/boost/files/latest/download)

        .\bootstrap mingw
        .\b2 toolset=gcc --build-type=minimal install --prefix=$install --with-program_options --with-system --with-filesystem --with-date_time --with-thread --with-regex --with-log --with-locale boost.locale.iconv=off

* build [yaml-cpp](https://code.google.com/p/yaml-cpp/downloads)

        cmake -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=$install -DCMAKE_INSTALL_PREFIX=$install .
        mingw32-make install

In Powershell:

    choco install cmake 7zip.commandline -y
    choco install mingw --params "/threads:win32" -y
    $env:PATH = "C:\tools\mingw64\bin;$env:PATH"
    $install = "C:\tools"

    (New-Object Net.WebClient).DownloadFile("https://downloads.sourceforge.net/boost/boost_1_54_0.7z", "$pwd/boost_1_54_0.7z")
    7za x boost_1_54_0.7z
    pushd boost_1_54_0
    .\bootstrap mingw
    .\b2 toolset=gcc --build-type=minimal install --prefix=$install --with-program_options --with-system --with-filesystem --with-date_time --with-thread --with-regex --with-log --with-locale boost.locale.iconv=off
    popd

    (New-Object Net.WebClient).DownloadFile("https://yaml-cpp.googlecode.com/files/yaml-cpp-0.5.1.tar.gz", "$pwd/yaml-cpp-0.5.1.tar.gz")
    7za x yaml-cpp-0.5.1.tar.gz
    7za x yaml-cpp-0.5.1.tar
    pushd yaml-cpp-0.5.1
    cmake -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="$install" -DCMAKE_INSTALL_PREFIX="$install" .
    mingw32-make install
    popd

Note that OpenSSL isn't needed on Windows.


Pre-Build
---------

All of the following examples start by assuming the current directory is the root of the repo.

Note the use of git submodules, so use `git clone --recursive` to ensure the submodules are populated.

On Windows, add `-G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=\<binary install path\> -DBOOST_STATIC=ON` to the `cmake` invocation.

Before building cfacter, use `cmake` to generate build files:

    $ mkdir release
    $ cd release
    $ cmake ..

To generate build files with debug information:

    $ mkdir debug
    $ cd debug
    $ cmake -DCMAKE_BUILD_TYPE=Debug ..

Build
-----

To build cfacter, use 'make':

    $ cd release
    $ make

To build cfacter with debug information:

    $ cd debug
    $ make

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

To run ruby tests (`make install` required):

    $ cd lib
    $ rspec

Install
-------

You can install cfacter into your system:

    $ cd release
    $ make && sudo make install

By default, cfacter will install files into `/usr/local/bin`, `/usr/local/lib`, and `/usr/local/include`.
If the project is configured with Ruby in the PATH, cfacter.rb will be installed to that Ruby's vendor dir.

To install to a different location, set the install prefix:

    $ cd release
    $ cmake -DCMAKE_INSTALL_PREFIX=~ ..
    $ make clean install

This would install cfacter into `~/bin`, `~/lib`, and `~/include`.

Ruby Usage
----------

Currently cfacter doesn't automatically define the Facter API when required.
This is to prevent cfacter from colliding with the Ruby version of Facter.

To use the Facter API from Ruby, call the `CFacter#initialize` method:

```ruby
    require 'cfacter'
    CFacter.initialize
    
    # Now use the Facter API...
    puts "kernel: #{Facter.value(:kernel)}"
```

Uninstall
---------

Run the following command to remove files that were previously installed:

    $ sudo xargs rm < release/install_manifest.txt

Documentation
-------------

To generate API documentation, install doxygen 1.8.7 or later.

    $ cd lib
    $ doxygen

To view the documentation, open `lib/html/index.html` in a web browser.
