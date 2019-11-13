#!/bin/bash

caller_directory=$(pwd)
script_directory=$(dirname $(realpath $0))

cd $script_directory/ext

# build native extensions
ruby extconf.rb
make

# revert path to caller directory
cd $caller_directory
