find_package(
  Python
  COMPONENTS Interpreter Development.Module
  REQUIRED)

find_package(
  SWIG
  COMPONENTS python
  REQUIRED)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(example_c SHARED example.c example.h)

include(UseSWIG)

swig_add_library(
  example
  LANGUAGE python OUTPUT_DIR "${SKBUILD_PLATLIB_DIR}"
  SOURCES example.i)
if(WIN32)
  set_property(TARGET example PROPERTY SUFFIX ".${Python_SOABI}.pyd")
else()
  set_property(TARGET example
               PROPERTY SUFFIX ".${Python_SOABI}${CMAKE_SHARED_MODULE_SUFFIX}")
endif()
target_link_libraries(example PRIVATE example_c Python::Module)

install(TARGETS example DESTINATION .)
install(TARGETS example_c DESTINATION .)
