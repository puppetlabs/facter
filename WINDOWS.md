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


## MinGW

*   Install tools

    * mingw-w64 4.8.2 (<http://win-builds.org/download.html>)

    * Set 64-bit gcc with '. /opt/windows_64/bin/win-builds-switch 64'

*   Build and install boost for mingw

    * ./boostrap (from cmd.exe)

    * ./b2 toolset=gcc variant=release link=shared install --prefix=\<install path\>

    * $env:BOOST_ROOT = "\<install path\>"

*   Build and install yaml-cpp

    * Relies on boost

    * cmake -G "MinGW Makefiles Win64" -DCMAKE_INSTALL_PREFIX=\<install path\> && mingw32-make && mingw32-make install

    * $env:YAMLCPP_ROOT = "\<install path\>"

