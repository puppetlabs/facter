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

    * cmake -G "Visual Studio 12 Win64" -DCMAKE_INSTALL_PREFIX=\<install path\> .. (use Win32 for 32-bit builds)

    * If using yaml-cpp-0.5.1, add #include \<algorithm\> to ostream_wrapper.cpp; you can avoid this by cloning the latest code from the yaml-cpp repo

    * $env:YAMLCPP_ROOT = "\<install path\>"


## MinGW

Boost builds with MinGW work best with MSYS, so we install it here. All commands below are assumed to be issued in MSYS with a default installation.

*   Install tools

    * Install mingw and msys (for make) using [mingw-get-setup](http://sourceforge.net/projects/mingw/files/)

    * Install [mingw-w64 4.8.2](http://win-builds.org/download.html) on top of msys

    * export PATH = "$PATH:/c/MinGW/msys/1.0/bin:/c/MinGW/bin"
    
    * Use '. /opt/windows_64/bin/win-builds-switch 64' for 64-bit builds
    
    * Use '. /opt/windows_32/bin/win-builds-switch 32' for 32-bit builds

*   Build and install boost for mingw

    * ./boostrap

    * ./b2 toolset=gcc variant=release link=shared install --prefix=\<install path\>

    * Note that some libraries will fail to build.

    * $env:BOOST_ROOT = "\<install path\>"

*   Build and install yaml-cpp

    * Relies on boost

    * cmake -G "MinGW Makefiles Win64" -DCMAKE_INSTALL_PREFIX=\<install path\> && mingw32-make && mingw32-make install (use Win32 for 32-bit builds)

    * $env:YAMLCPP_ROOT = "\<install path\>"
