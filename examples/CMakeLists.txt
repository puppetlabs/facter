cmake_minimum_required(VERSION 3.2.2)

# Set compiler-specific flags
set(CMAKE_CXX_FLAGS ${FACTER_CXX_FLAGS})

include_directories(
    ../lib/inc # the libfacter headers
)

add_executable(cppodm odm.cpp)
target_link_libraries(cppodm odm)