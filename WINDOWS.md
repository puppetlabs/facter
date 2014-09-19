# Setup for Windows

Documented below are notes on setting up required libraries to build cfacter on Windows.

General instructions

*   Install OpenSSL

    * Download "Win64 OpenSSL v1.0.1i" from <http://slproweb.com/products/Win32OpenSSL.html> (use Win32 for 32-bit builds)

    * Get and install "Visual C++ 2008 Redistributables (x64)" (use non-x86 for 32-bit builds)

    * Install OpenSSL: choose install path; choose to copy files to OpenSSL /bin directory (not system dir).

	* Set the environment variable OPENSSL_ROOT = "\<install path\>"

*   Install Python for cpplint

	* Install from python.org, or using "choco install python".

*   A script for bootstrapping a system following the MinGW instructions below can be found at https://gist.github.com/MikaelSmith/d885c72dd87e61e3f969

    It is a work in progress, and will likely be merged into the puppetlabs/cfacter-build project eventually.


## MinGW

Commands are expected to be executed in cmd.exe or Powershell. MinGW and Cygwin do not interact well. MSYS may work.

*   Install tools

    * MinGW-w64 installer (<http://sourceforge.net/projects/mingw-w64/>); select Version=4.8.2, Architecture based on 32 or 64-bit target, Threads=win32
        * The MinGW-w64 project provides a shortcut to open a cmd shell with GCC in the PATH

*   Build and install boost for mingw

    * Download Boost 1.55 (<http://sourceforge.net/projects/boost/files/boost/1.55.0/>)

    * .\boostrap mingw

    * .\b2 toolset=gcc address-model=64 --build-type=minimal install --prefix=\<boost install path\>
        * --with-program_options --with-system --with-filesystem --with-date_time --with-thread --with-regex --with-log can be used for a fast minimal build

    * Note that some libraries are expected to fail to build.

*   Build and install yaml-cpp

    * Depends on boost

    * mkdir build && cd build && cmake -G "MinGW Makefiles" -DBOOST_ROOT=\<boost install path\> -DCMAKE_INSTALL_PREFIX=\<install path\> && mingw32-make install

*   Build CFACTER

    * mkdir release && cd release && cmake -G "MinGW Makefiles" -DBOOST_ROOT=\<boost install path\> -DOPENSSL_ROOT=\<openssl install path\> -DYAMLCPP_ROOT=\<yaml-cpp install path\> .. && mingw32-make


## Visual Studio Express 2013 for Windows Desktop (not currently supported)

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
