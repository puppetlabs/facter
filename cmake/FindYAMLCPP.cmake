include(FindDependency)

if(YAMLCPP_STATIC)
  set(yaml_lib "libyaml-cpp.a")
else()
  set(yaml_lib "yaml-cpp")
endif()

if (WIN32)
  find_dependency(YAMLCPP DISPLAY "yaml-cpp" HEADERS "yaml-cpp/yaml.h" LIBRARIES "libyaml-cppmd" "yaml-cpp")
else()
  find_dependency(YAMLCPP DISPLAY "yaml-cpp" HEADERS "yaml-cpp/yaml.h" LIBRARIES ${yaml_lib})
endif()

include(FeatureSummary)
set_package_properties(YAMLCPP PROPERTIES DESCRIPTION "A YAML emitter and parser written in C++" URL "https://code.google.com/p/yaml-cpp/")
set_package_properties(YAMLCPP PROPERTIES TYPE REQUIRED PURPOSE "Enables support for outputting facts as YAML.")
