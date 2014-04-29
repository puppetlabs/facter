#! /bin/bash

# Travis cpp jobs construct a matrix based on environment variables
# (and the value of 'compiler'). In order to test multiple builds
# (release/debug/cpplint), this uses a TRAVIS_TARGET env var to
# do the right thing.
#
# Note that it assumes cmake is at $HOME/bin which is an artifact
# of the before_install step in this project's .travis.yml.

function travis_make()
{
    mkdir $1 && cd $1

    # cmake
    [ $1 == "debug" ] && export CMAKE_VARS="  -DCMAKE_BUILD_TYPE=Debug "
    $HOME/bin/cmake $CMAKE_VARS ..

    # make
    [ $1 == "cpplint" ] && export MAKE_TARGET=" cpplint "
    make $MAKE_TARGET
}

case $TRAVIS_TARGET in
  "CPPLINT" ) travis_make cpplint ;;
  "RELEASE" ) travis_make release ;;
  "DEBUG" )   travis_make debug ;;
  *)          echo "Nothing to do!"
esac
