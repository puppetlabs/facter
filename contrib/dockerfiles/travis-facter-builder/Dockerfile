# Setup environment
FROM mikaelsmith/travis-cpp-builder:12.04
MAINTAINER Michael Smith <michael.smith@puppetlabs.com>

# Add boost and libblkid
RUN apt-get -y install libssl-dev
RUN apt-get -y install libcurl4-openssl-dev
RUN apt-get -y install libblkid-dev
RUN apt-get -y install libboost-filesystem1.55-dev libboost-program-options1.55-dev libboost-regex1.55-dev libboost-date-time1.55-dev libboost-thread1.55-dev libboost-log1.55-dev libboost-locale1.55-dev libboost-chrono1.55-dev

# Build and install yaml-cpp
RUN wget https://yaml-cpp.googlecode.com/files/yaml-cpp-0.5.1.tar.gz -O yaml-cpp-0.5.1.tgz && \
    tar xzf yaml-cpp-0.5.1.tgz && \
    cd yaml-cpp-0.5.1 && \
    cmake -DBUILD_SHARED_LIBS=ON . && \
    make > /dev/null && \
    make install > /dev/null && \
    cd .. && \
    rm -r yaml-cpp-0.5.1.tgz yaml-cpp-0.5.1

# Setup facter project
RUN git clone --recursive https://github.com/puppetlabs/facter /root/facter

