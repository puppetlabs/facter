Native Facter
=============

An implementation of facter functionality in C++11, providing:

* a shared library which gather facts about the system
* an executable for standalone command line usage
* a ruby file to enable `require 'facter'`.

Please see our [extensibility document](https://github.com/puppetlabs/facter/blob/master/Extensibility.md) to learn more
about extending native facter using custom and external facts.

Build Requirements
------------------

* GCC 4.8+ or Clang 5.0+ (OSX)
* CMake >= 3.2.2
* Boost C++ Libraries >= 1.54
* yaml-cpp >= 0.5.1

Currently the leatherman library is vendored as a git submodule.  To ensure submodules are initialized, please run:

**`git submodule update --init`**

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

    yum install boost-devel openssl-devel yaml-cpp-devel libblkid-devel libcurl-devel gcc-c++ make wget tar
    wget http://www.cmake.org/files/v3.2/cmake-3.2.3-Linux-x86_64.tar.gz
    tar xzvf cmake-3.2.3-Linux-x86_64.tar.gz --strip 1 -C /usr/local

### Setup on Mac OSX Mavericks (homebrew)

This assumes Clang is installed and the system OpenSSL libraries will be used.

The following will install all required libraries:

    brew install cmake boost yaml-cpp

### Setup on Ubuntu 14.04 (Trusty)

The following will install most required tools and libraries:

    apt-get install build-essential libboost-all-dev libssl-dev libyaml-cpp-dev libblkid-dev libcurl4-openssl-dev wget tar
    wget http://www.cmake.org/files/v3.2/cmake-3.2.3-Linux-x86_64.tar.gz
    tar xzvf cmake-3.2.3-Linux-x86_64.tar.gz --strip 1 -C /usr/local

### Setup on Windows

[MinGW-w64](http://mingw-w64.sourceforge.net/) is used for full C++11 support, and [Chocolatey](https://chocolatey.org) can be used to install. You should have at least 2GB of memory for compilation.

* install [CMake](https://chocolatey.org/packages/cmake)
* install [MinGW-w64](https://chocolatey.org/packages/mingw)

        choco install mingw --params "/threads:win32"

For the remaining tasks, build commands can be executed in the shell from Start > MinGW-w64 project > Run Terminal

* select an install location for dependencies, such as C:\\tools or cmake\\release\\ext; we'll refer to it as $install

* build [Boost](http://sourceforge.net/projects/boost/files/latest/download)

        .\bootstrap mingw
        .\b2 toolset=gcc --build-type=minimal install --prefix=$install --with-program_options --with-system --with-filesystem --with-date_time --with-thread --with-regex --with-log --with-locale --with-chrono boost.locale.iconv=off

* build [yaml-cpp](https://code.google.com/p/yaml-cpp/downloads)

        cmake -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=$install -DCMAKE_INSTALL_PREFIX=$install .
        mingw32-make install

* build [libcurl](http://curl.haxx.se/download)

        mingw32-make mingw32
        cp -r include\curl $install\include
        cp -r lib\libcurl.a $install\lib

In Powershell:

    choco install cmake 7zip.commandline -y
    choco install mingw --params "/threads:win32" -y
    $env:PATH = "C:\tools\mingw64\bin;$env:PATH"
    $install = "C:\tools"

    (New-Object Net.WebClient).DownloadFile("https://downloads.sourceforge.net/boost/boost_1_54_0.7z", "$pwd/boost_1_54_0.7z")
    7za x boost_1_54_0.7z
    pushd boost_1_54_0
    .\bootstrap mingw
    .\b2 toolset=gcc --build-type=minimal install --prefix=$install --with-program_options --with-system --with-filesystem --with-date_time --with-thread --with-regex --with-log --with-locale --with-chrono boost.locale.iconv=off
    popd

    (New-Object Net.WebClient).DownloadFile("https://yaml-cpp.googlecode.com/files/yaml-cpp-0.5.1.tar.gz", "$pwd/yaml-cpp-0.5.1.tar.gz")
    7za x yaml-cpp-0.5.1.tar.gz
    7za x yaml-cpp-0.5.1.tar
    pushd yaml-cpp-0.5.1
    cmake -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="$install" -DCMAKE_INSTALL_PREFIX="$install" .
    mingw32-make install
    popd

    (New-Object Net.WebClient).DownloadFile("http://curl.haxx.se/download/curl-7.42.1.zip", "$pwd/curl-7.42.1.zip")
    7za x curl-7.42.1.zip
    pushd curl-7.42.1
    mingw32-make mingw32
    cp -r include\curl $install\include
    cp -r lib\libcurl.a $install\lib
    popd

Note that OpenSSL isn't needed on Windows.


Pre-Build
---------

All of the following examples start by assuming the current directory is the root of the repo.

On Windows, add `-G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=\<binary install path\> -DBOOST_STATIC=ON` to the `cmake` invocation.

Before building facter, use `cmake` to generate build files:

    $ mkdir release
    $ cd release
    $ cmake ..

To generate build files with debug information:

    $ mkdir debug
    $ cd debug
    $ cmake -DCMAKE_BUILD_TYPE=Debug ..

Build
-----

To build facter, use 'make':

    $ cd release
    $ make

To build facter with debug information:

    $ cd debug
    $ make

Run
---

You can run facter from where it was built:

`$ release/bin/facter`

For a debug build:

`$ debug/bin/facter`

Test
----

If a ruby was found during configuration, execute the following command before running tests:

    $ bundle install --gemfile lib/Gemfile

You can run facter tests using the test target:

    $ cd release
    $ make test

For a debug build:

    $ cd debug
    $ make test

For verbose test output, run `ctest` instead of using the test target:

    $ cd release
    $ ctest -V

Install
-------

You can install facter into your system:

    $ cd release
    $ make && sudo make install

By default, facter will install files into `/usr/local/bin`, `/usr/local/lib`, and `/usr/local/include`.
If the project is configured with Ruby in the PATH, facter.rb will be installed to that Ruby's vendor dir.

To install to a different location, set the install prefix:

    $ cd release
    $ cmake -DCMAKE_INSTALL_PREFIX=~ ..
    $ make clean install

This would install facter into `~/bin`, `~/lib`, and `~/include`.

Ruby Usage
----------

Using the Ruby API requires that facter.rb is installed into the Ruby load path, as done in the previous install steps.

```ruby
    require 'facter'
    
    # Use the Facter API...
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
