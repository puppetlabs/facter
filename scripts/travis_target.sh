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
if [ ${TRAVIS_TARGET} == COMMITS ]; then
  shopt -s nocasematch
  git log --no-merges --pretty=%s master..$HEAD | while read line ; do
    if [[ ! "$line" =~ ^\((maint|doc|packaging|fact-[0-9]+)\)|revert ]]; then
      echo -e \
          "\n\n\n\tThis commit summary didn't match CONTRIBUTING.md guidelines:\n" \
          "\n\t\t$line\n" \
          "\tThe commit summary (i.e. the first line of the commit message) should start with one of:\n" \
          "\t\t(FACT-<digits>) # this is most common and should be a ticket at tickets.puppetlabs.com\n" \
          "\t\t(doc)\n" \
          "\t\t(maint)\n" \
          "\t\t(packaging)\n" \
          "\n\tThis test for the commit summary is case-insensitive.\n\n\n"
      exit 1
    fi
  done
  exit 0
elif [ ${TRAVIS_TARGET} == DEBUG ]; then
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
    # Ignore coveralls failures, keep service success uncoupled
    coveralls --gcov gcov-4.8 --gcov-options '\-lp' -r .. >/dev/null || true
  fi
fi

