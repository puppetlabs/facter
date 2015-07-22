#!/bin/bash
set -ev

# Set compiler to GCC 4.8 here, as Travis overrides the global variables.
export CC=gcc-4.8 CXX=g++-4.8

if [ ${TRAVIS_TARGET} == CPPCHECK ]; then
  # grab a pre-built cppcheck from s3
  wget https://s3.amazonaws.com/kylo-pl-bucket/pcre-8.36_install.tar.bz2
  tar xjvf pcre-8.36_install.tar.bz2 --strip 1 -C $USERDIR
  wget https://s3.amazonaws.com/kylo-pl-bucket/cppcheck-1.69_install.tar.bz2
  tar xjvf cppcheck-1.69_install.tar.bz2 --strip 1 -C $USERDIR
elif [ ${TRAVIS_TARGET} == DOXYGEN ]; then
  # grab a pre-built doxygen 1.8.7 from s3
  wget https://s3.amazonaws.com/kylo-pl-bucket/doxygen_install.tar.bz2
  tar xjvf doxygen_install.tar.bz2 --strip 1 -C $USERDIR
elif [ ${TRAVIS_TARGET} == DEBUG ]; then
  # Install coveralls.io update utility
  pip install --user cpp-coveralls
fi

# Generate build files
if [ ${TRAVIS_TARGET} == DEBUG ]; then
  cmake -DCMAKE_BUILD_TYPE=Debug -DCOVERALLS=ON .
else
  cmake .
fi

if [ ${TRAVIS_TARGET} == CPPLINT ]; then
  make cpplint
elif [ ${TRAVIS_TARGET} == DOXYGEN ]; then
  # Build docs
  pushd lib
  doxygen 2>&1 | ( ! grep . )
  ruby docs/generate.rb > /tmp/facts.md
  popd
elif [ ${TRAVIS_TARGET} == CPPCHECK ]; then
  make cppcheck
else
  make -j2

  # Install the bundle before testing
  bundle install --gemfile=lib/Gemfile
  make test ARGS=-V

  # Make sure installation succeeds
  make DESTDIR=$USERDIR install

  if [ ${TRAVIS_TARGET} == DEBUG ]; then
    coveralls --gcov gcov-4.8 --gcov-options '\-lp' -r .. >/dev/null
  fi
fi

