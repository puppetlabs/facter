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

`$ cmake -DCMAKE_BUILD_TYPE= . && make clean all`

Run
---

You can run cfacter from where it was built:

`$ exe/cfacter`

Install
-------

You can install cfacter into your system:

`$ sudo make install`

By default, this will install cfacter into `/usr/local/bin`, using an install prefix of `/usr/local`.

To install with a different prefix:

`$ cmake -DCMAKE_INSTALL_PREFIX=/usr . && sudo make clean install`

This would install cfacter into `/usr/bin`.

Uninstall
---------

Run the following command to remove files that were previously installed:

`$ sudo xargs rm < install_manifest.txt`