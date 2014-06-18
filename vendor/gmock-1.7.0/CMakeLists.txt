find_package(Threads)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/gtest/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/gtest)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_library(gmock_main STATIC EXCLUDE_FROM_ALL gtest/src/gtest-all.cc src/gmock-all.cc src/gmock_main.cc)
target_link_libraries(gmock_main ${CMAKE_THREAD_LIBS_INIT})

set(GMOCK_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/vendor/gmock-1.7.0/include" "${CMAKE_SOURCE_DIR}/vendor/gmock-1.7.0/gtest/include" PARENT_SCOPE)
set(GMOCK_LIBRARIES gmock_main PARENT_SCOPE)
