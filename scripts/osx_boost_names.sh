#!/bin/sh

if [ "$#" -eq 0 ]; then
    echo "usage: osx_boost_names <source_dir>"
    exit 1
fi

# Search for all dynamic libraries in the given source directory
files=$(find $1 -type f -name '*.dylib')
for i in $files
do
    # Fix the install_name so that it starts with @rpath
    filename=$(basename $i)
    echo "Fixing boost install names for: $filename"
    install_name_tool -id @rpath/$filename $i
    if [ "$?" != "0" ]; then
        exit 1
    fi
    # Look for all the other dynamic libraries and fix their references to this library
    for j in $files
    do
        if [ "$i" == "$j" ]; then
            continue
        fi
        install_name_tool -change $filename @rpath/$filename $j
    done
done
