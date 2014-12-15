# Setup for Windows

Documented below are notes on setting up required libraries to build cfacter on Windows.

Setup Instructions

*   Install CMake

    * http://www.cmake.org/download/
    * or: choco install cmake

*   Install Python for cpplint

    * choco install python

	* or: Install from python.org
        * eg: https://www.python.org/ftp/python/3.4.1/python-3.4.1.amd64.msi

*   Install Doxygen for document generation

    * choco install doxygen.install

*   A script for bootstrapping a system following the MinGW instructions below can be found at https://gist.github.com/MikaelSmith/d885c72dd87e61e3f969

    It is a work in progress, and will likely be merged into the puppetlabs/cfacter-build project eventually.


## MinGW

Commands are expected to be executed in cmd.exe or Powershell. MinGW and Cygwin do not interact well. MSYS may work.

*   Install tools

    * choco install mingw
        * restart your shell or it won't get the new path
        * note that the mingw version on Chocolatey won't work for Ruby facts, as sjlj exception handling conflicts with libruby's error handling

    * or: MinGW-w64 installer (<http://sourceforge.net/projects/mingw-w64/>); select Version=4.8.2, Architecture based on 32 or 64-bit target, Threads=win32
        * The MinGW-w64 project provides a shortcut to open a cmd shell with GCC in the PATH

*   Build and install Boost C++ libs with MinGW

    * If you run into problems building in Powershell, try cmd.exe

    * Download Boost 1.56 (<http://sourceforge.net/projects/boost/files/boost/1.56.0/>)

    * .\bootstrap mingw

    * .\b2 toolset=gcc address-model=64 --build-type=minimal install --prefix=\<boost install path\> boost.locale.iconv=off
        * --with-program_options --with-system --with-filesystem --with-date_time --with-thread --with-regex --with-log --with-locale can be used for a fast minimal build

    * Note that some libraries are expected to fail to build.

*   Build and install yaml-cpp

    * Depends on Boost

    * Source at <https://code.google.com/p/yaml-cpp/>
 
    * mkdir build && cd build && cmake -G "MinGW Makefiles" -DBOOST_ROOT=\<boost install path\> -DCMAKE_INSTALL_PREFIX=\<install path\> && mingw32-make install

*   Build CFACTER

    * git clone --recursive https://github.com/puppetlabs/cfacter.git

    * cd cfacter && mkdir release && cd release

    * cmake -G "MinGW Makefiles" -DBOOST_ROOT=\<boost install path\> -DOPENSSL_ROOT=\<openssl install path\> -DYAMLCPP_ROOT=\<yaml-cpp install path\> -DBOOST_STATIC=ON .. && mingw32-make


## Visual Studio Express 2013 for Windows Desktop (not currently supported)

The commands below are all assumed to be run in Windows PowerShell. These are just notes for when Visual Studio support is completed.

*   Install boost from binary

    * Download boost_1_55_0-msvc-12.0-64.exe from <http://sourceforge.net/projects/boost/files/boost-binaries/> (-32.exe for 32-bit builds)

    * Use BOOST_LIBRARYDIR to point to lib64-msvc-12.0

*   Build and install yaml-cpp

    * cmake -G "Visual Studio 12 Win64" -DCMAKE_INSTALL_PREFIX=\<install path\> .. (use Win32 for 32-bit builds)

    * If using yaml-cpp-0.5.1, add #include \<algorithm\> to ostream_wrapper.cpp; you can avoid this by cloning the latest code from the yaml-cpp repo

*   Build CFACTER

    * cmake -G "Visual Studio 12 Win64" ..
