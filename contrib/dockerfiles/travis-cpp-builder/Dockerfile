# Setup environment
FROM ubuntu:12.04
MAINTAINER Michael Smith <michael.smith@puppetlabs.com>

# Setup repos
RUN apt-get -y install python-software-properties
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN add-apt-repository -y ppa:boost-latest/ppa
RUN apt-get update

# Setup compiler
RUN apt-get -y install gcc-4.8 g++-4.8
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50

# Install build tools
RUN apt-get -y install bzip2
RUN apt-get -y install vim
RUN apt-get -y install man
RUN apt-get -y install xmlto
RUN apt-get -y install git
RUN apt-get -y install ruby1.9.3
RUN apt-get -y install wget
RUN apt-get -y install make
RUN apt-get -y install flex
RUN apt-get -y install bison
RUN apt-get -y install cppcheck
RUN wget https://s3.amazonaws.com/kylo-pl-bucket/cmake_install.tar.bz2 && \
    tar xjf cmake_install.tar.bz2 --strip 1 -C /usr/local && \
    rm cmake_install.tar.bz2

# Build and install doxygen
RUN wget https://github.com/doxygen/doxygen/archive/Release_1_8_7.tar.gz -O doxygen-1.8.7.tgz && \
    tar xzf doxygen-1.8.7.tgz && \
    cd doxygen-Release_1_8_7 && \
    ./configure > /dev/null && \
    make > /dev/null && \
    make install > /dev/null && \
    cd .. && \
    rm -r doxygen-1.8.7.tgz doxygen-Release_1_8_7

# Build and install cppcheck
RUN wget http://sourceforge.net/projects/pcre/files/pcre/8.36/pcre-8.36.tar.bz2 -O pcre-8.36.tar.bz2 && \
    tar xjf pcre-8.36.tar.bz2 && \
    cd pcre-8.36 && \
    ./configure > /dev/null && \
    make install > /dev/null && \
    cd .. && \
    rm -r pcre-8.36.tar.bz2 pcre-8.36
RUN wget http://sourceforge.net/projects/cppcheck/files/cppcheck/1.68/cppcheck-1.68.tar.bz2 -O cppcheck-1.68.tar.bz2 && \
    tar xjf cppcheck-1.68.tar.bz2 && \
    cd cppcheck-1.68 && \
    make install SRCDIR=build CFGDIR=/usr/local/cfg HAVE_RULES=yes > /dev/null && \
    cd .. && \
    rm -r cppcheck-1.68.tar.bz2 cppcheck-1.68

