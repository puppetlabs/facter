#! /bin/bash

# Travis cpp jobs construct a matrix based on environment variables
# (and the value of 'compiler'). In order to test multiple builds
# (release/debug/cpplint/cppcheck), this uses a TRAVIS_TARGET env
# var to do the right thing.
#
# Note that it assumes cmake is at $HOME/bin which is an artifact
# of the before_install step in this project's .travis.yml.

function travis_make()
{
    mkdir $1 && cd $1

    # Generate build files
    [ $1 == "debug" ] && export CMAKE_VARS="-DCMAKE_BUILD_TYPE=Debug -DCOVERALLS=ON"
    $HOME/bin/cmake $CMAKE_VARS ..
    if [ $? -ne 0 ]; then
        echo "cmake failed."
        exit 1
    fi

    # Build facter
    if [ $1 == "cpplint" ]; then
        export MAKE_TARGET="cpplint"
    elif [ $1 == "cppcheck" ]; then
        export MAKE_TARGET="cppcheck"
    else
        export MAKE_TARGET="all"
    fi
    make $MAKE_TARGET
    if [ $? -ne 0 ]; then
        echo "build failed."
        exit 1
    fi

    # Run tests if not doing cpplint/cppcheck
    if [ $1 == "cpplint" ]; then
        # Verify documentation
        pushd ../lib
        doxygen
        if [[ -s html/warnings.txt ]]; then
            cat html/warnings.txt
            echo "documentation failed."
            exit 1
        fi
        ruby docs/generate.rb > /tmp/facts.md
        if [ $? -ne 0 ]; then
            echo "fact documentation failed."
            exit 1
        fi
        popd
    elif [ $1 != "cppcheck" ]; then
        LD_PRELOAD=/lib/x86_64-linux-gnu/libSegFault.so ctest -V 2>&1 | c++filt
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            echo "tests reported an error."
            exit 1
        fi

        if [ $1 == "debug" ]; then
            coveralls --gcov-options '\-lp' -r .. --exclude ../acceptance >/dev/null
        fi

        # Install into the system for the spec tests 
        sudo make install
        if [ $? -ne 0 ]; then
            echo "install failed."
            exit 1
        fi
        sudo ldconfig

        pushd ../lib
        bundle install
        if [ $? -ne 0 ]; then
            echo "bundle install failed."
            exit 1
        fi
        rspec 2>&1 | c++filt
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            echo "ruby specs failed."
            exit 1
        fi
        popd
    fi
}

case $TRAVIS_TARGET in
  "CPPLINT" )  travis_make cpplint ;;
  "CPPCHECK" ) travis_make cppcheck ;;
  "RELEASE" )  travis_make release ;;
  "DEBUG" )    travis_make debug ;;
  *)           echo "Nothing to do!"
esac
