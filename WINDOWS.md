# Setup for Windows

Documented below are notes on setting up required libraries to build cfacter on Windows.

In either case

*   Install OpenSSL

    * Download "Win64 OpenSSL V1.0.1h" from <http://slproweb.com/products/Win32OpenSSL.html> (use Win32 for 32-bit builds)

    * Get and install "Visual C++ 2008 Redistributables (x64)" (use non-x86 for 32-bit builds)

    * Install OpenSSL: choose install path; choose to copy files to OpenSSL /bin directory (not system dir).

	* Set the environment variable OPENSSL_ROOT = "\<install path\>"

*   Install Python for cpplint

	* Install from python.org, or using "choco install python".


## Visual Studio Express 2013 for Windows Desktop

The commands below are all assumed to be run in Windows PowerShell.

To set an environment variable in PowerShell, use $env:VARIABLE = "value".

*   Install boost from binary

    * Download boost_1_55_0-msvc-12.0-64.exe from <http://sourceforge.net/projects/boost/files/boost-binaries/> (-32.exe for 32-bit builds)
    
    * $env:BOOST_ROOT = "\<install path\>"

    * $env:BOOST_LIBRARYDIR = "\<install path\>\lib64-msvc-12.0"

*   Build and install yaml-cpp

    * Relies on boost (setting BOOST_ROOT/BOOST_LIBRARYDIR is sufficient)

    * Source at <https://code.google.com/p/yaml-cpp/>

    * mkdir build && cd build && cmake -G "Visual Studio 12 Win64" -DCMAKE_INSTALL_PREFIX=\<install path\> .. (use Win32 for 32-bit builds)

    * If using yaml-cpp-0.5.1, add #include \<algorithm\> to ostream_wrapper.cpp; you can avoid this by cloning the latest code from the yaml-cpp repo

    * $env:YAMLCPP_ROOT = "\<install path\>"

*   Build CFACTER

    * mkdir release && cd release && cmake -G "Visual Studio 12 Win64" ..

## MinGW

Boost builds with MinGW work best with MSYS, so we install it here. All commands below are assumed to be issued in MSYS with a default installation.

*   Install tools

    * TDM64 MinGW bundle (<http://tdm-gcc.tdragon.net/>), recommended by the MinGW-w64 project for building Boost (<http://sourceforge.net/p/mingw-w64/wiki2/BuildingBoost/>). TDM installer updates PATH.

    * The following commands are executed in cmd.exe

*   Build and install boost for mingw

    * .\boostrap

    * .\b2 toolset=gcc variant=release link=shared install --prefix=\<boost install path\>

    * Note that some libraries will fail to build.

*   Build and install yaml-cpp

    * Relies on boost

    * mkdir build && cd build && cmake -G "MinGW Makefiles" -DBOOST_ROOT=\<boost install path\> -DCMAKE_INSTALL_PREFIX=\<install path\> && mingw32-make install

    * set YAMLCPP_ROOT "\<install path\>"

*   Build CFACTER

    * mkdir release && cd release && cmake -G "MinGW Makefiles" -DBOOST_ROOT=\<boost install path\> -DOPENSSL_ROOT=\<openssl install path\> -DYAMLCPP_ROOT=\<yaml-cpp install path\> .. && mingw32-make
