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

    # Generate build files
    [ $1 == "debug" ] && export CMAKE_VARS="  -DCMAKE_BUILD_TYPE=Debug "
    $HOME/bin/cmake $CMAKE_VARS ..
    if [ $? -ne 0 ]; then
        echo "cmake failed."
        exit 1
    fi

    # Build cfacter
    [ $1 == "cpplint" ] && export MAKE_TARGET=" cpplint "
    make $MAKE_TARGET
    if [ $? -ne 0 ]; then
        echo "build failed."
        exit 1
    fi

    # Run library tests if not doing cpplint
    if [ $1 != "cpplint" ]; then
        ctest -V
        if [ $? -ne 0 ]; then
            echo "tests reported an error."
            exit 1
        fi
    fi
}

case $TRAVIS_TARGET in
  "CPPLINT" ) travis_make cpplint ;;
  "RELEASE" ) travis_make release ;;
  "DEBUG" )   travis_make debug ;;
  *)          echo "Nothing to do!"
esac
