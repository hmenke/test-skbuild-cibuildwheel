include_directories(${CMAKE_CURRENT_SOURCE_DIR})

find_package(GSL REQUIRED)

add_library(example_c SHARED example.c example.h)
target_link_libraries(example_c PUBLIC GSL::gsl GSL::gslcblas)

find_package(
  Python
  COMPONENTS Interpreter Development.Module
  REQUIRED)

find_package(
  SWIG
  COMPONENTS python
  REQUIRED)

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
set_target_properties(example PROPERTIES
  INSTALL_RPATH $<$<BOOL:${SKBUILD}>:$<$<PLATFORM_ID:Linux>:$ORIGIN>$<$<PLATFORM_ID:Darwin>:@loader_path>>)

install(TARGETS example DESTINATION .)
install(TARGETS example_c DESTINATION .)
