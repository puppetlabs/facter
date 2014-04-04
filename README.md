cfacter
=======

Tinkering with a C/C++ facter

Requirements
------------

* CMake >= 2.8

Generating Build Files
----------------------

Before building cfacter, use `cmake` to generate build files:

`$ cmake .`

Build
-----

To build cfacter, use 'make':

`$ make`

To build cfacter with debug information:

`$ cmake -DCMAKE_BUILD_TYPE=Debug . && make clean all`

To turn off debug information:

`$ cmake -UCMAKE_BUILD_TYPE . && make clean all`

Run
---

You can run cfacter from where it was built:

`$ exe/cfacter`

Install
-------

You can install cfacter into your system:

`$ make && sudo make install`

By default, this will install cfacter into `/opt/cfacter`.

To install to a different location, set the install prefix:

`$ cmake -DCMAKE_INSTALL_PREFIX=~/cfacter . && make clean install`

This would install cfacter into `~/cfacter`.

Uninstall
---------

Run the following command to remove files that were previously installed:

`$ sudo xargs rm < install_manifest.txt`