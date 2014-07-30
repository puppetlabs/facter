# Setup for Windows

Documented below are notes on setting up required libraries to build cfacter on Windows.

In either case

*   Install OpenSSL

    * Download "Win64 OpenSSL V1.0.1h" from <http://slproweb.com/products/Win32OpenSSL.html>

    * Get and install "Visual C++ 2008 Redistributables (x64)

    * Install OpenSSL: choose install path; choose to copy files to OpenSSL /bin directory (not system dir).

	* Set the environment variable OPENSSL_ROOT = "\<install path\>"

*   Install Python for cpplint

	* Install from python.org, or using "choco install python".


## Visual Studio Express 2013 for Windows Desktop

The commands below are all assumed to be run in Windows PowerShell.

To set an environment variable in PowerShell, use $env:VARIABLE = "value".

*   Install boost from binary

    * Download installer from <http://www.boost.org/users/download/>
    
    * $env:BOOST_ROOT = "\<install path\>"

    * $env:BOOST_LIBRARYDIR = "\<install path\>\lib64-msvc-12.0"

*   Build and install Apache log4cxx

    * See <http://stackoverflow.com/questions/8461123/building-log4cxx-in-vs-2010-c>

	* Unzip log4cxx_vs2010.7z

	* Open log4cxx_vs2010/apache-log4cxx-0.10.0/projects/log4cxx.sln

	* Select Release/x64

    * Build log4cxx

    * mkdir -p \<install path\>/{include,lib}

    * cp projects/Release/log4cxx.lib \<install path\>/lib

    * cp src/main/include/log4cxx \<install path\>/include

    * Cleanup include files?

    * $env:LOG4CXX_ROOT = "\<install path\>"

*   Install openssl

    * Download "Win64 OpenSSL V1.0.1h" from <http://slproweb.com/products/Win32OpenSSL.html>

    * Get and install "Visual C++ 2008 Redistributables (x64)"

    * Install OpenSSL: choose install path; choose to copy files to OpenSSL /bin directory (not system dir).

    * $env:OPENSSL_ROOT = "\<install path\>"

*   Build and install yaml-cpp

    * Relies on boost (setting BOOST_ROOT/BOOST_LIBRARYDIR is sufficient).
    
    * Source at <https://code.google.com/p/yaml-cpp/>

    * cmake -G "Visual Studio 12 Win64" -DCMAKE_INSTALL_PREFIX=\<install path\> ..

    * (Had to add #include <algorithm\> in ostream_wrapper.cpp to build with VC++)

    * $env:YAMLCPP_ROOT = "\<install path\>"

*   Build and install RE2

    * Use <http://code.google.com/p/re2win/>

    * Add new configuration: x64

    * Build and copy lib and include files.

    * $env:RE2_ROOT = "\<install path\>"



## MinGW

*   Install tools

    * mingw, msys, msysDTK using mingw-get (<https://sourceforge.net/downloads/mingw>)

    * mingw-w64 4.8.2 (<http://win-builds.org/download.html>)

    * Set 64-bit gcc with '. /opt/windows_64/bin/win-builds-switch 64'

*   Build and install boost for mingw

    * .\boostrap (from cmd.exe)

    * ./b2 toolset=gcc variant=release link=shared install --prefix=\<install path\>

    * $env:BOOST_ROOT = "\<install path\>"

*   Build and install Apache log4cxx

    * <http://wiki.apache.org/logging-log4cxx/MSWindowsBuildInstructions>

    * Used mingw32-libexpat, apr/apr-util/log4cxx from repos

    * Modified apr/configure.in to use ssize_t_fmt="Id", size_t_fmt="Iu" in mingw

    * ... never got it built.

    * $env:LOG4CXX_ROOT = "\<install path\>"

*   Build and install yaml-cpp

    * Relies on boost

    * cmake -G "MinGW Makefiles Win64" -DCMAKE_INSTALL_PREFIX=\<install path\> && mingw32-make && mingw32-make install

    * $env:YAMLCPP_ROOT = "\<install path\>"

*   Build and install RE2

    * Use <http://code.google.com/p/re2/>

    * make && make DESTDIR=\<install path\> install

    * Get rid of extra usr/local (hard-coded in Makefile)

    * $env:RE2_ROOT = "\<install path\>"
