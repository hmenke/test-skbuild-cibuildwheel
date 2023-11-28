include_directories(${CMAKE_CURRENT_SOURCE_DIR})

find_package(GSL REQUIRED)

add_library(example_c SHARED example.c example.h)
target_link_libraries(example_c PUBLIC GSL::gsl GSL::gslcblas)

find_package(
  Python3
  COMPONENTS Interpreter Development.Module
  REQUIRED)

if(MSVC)
  string(REPLACE "python3${Python3_VERSION_MINOR}.lib" "python3.lib" Python3_LIBRARIES_GENERALIZED ${Python3_LIBRARIES})
  message(STATUS "Unpatched Python3 libraries: ${Python3_LIBRARIES}")
  message(STATUS "  Patched Python3 libraries: ${Python3_LIBRARIES_GENERALIZED}")
  foreach(Python3_LIBRARY ${Python3_LIBRARIES_GENERALIZED})
    if(NOT EXISTS ${Python3_LIBRARY})
      message(FATAL_ERROR "${Python3_LIBRARY}: No such file or directory")
    endif()
  endforeach()
endif()

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
  set_property(TARGET example PROPERTY SUFFIX ".${Python3_SOABI}.pyd")
else()
  set_property(TARGET example
               PROPERTY SUFFIX ".${Python3_SOABI}${CMAKE_SHARED_MODULE_SUFFIX}")
endif()
target_link_libraries(example PRIVATE example_c $<$<CXX_COMPILER_ID:MSVC>:${Python3_LIBRARIES_GENERALIZED}>)
set_target_properties(example PROPERTIES
  SWIG_GENERATED_INCLUDE_DIRECTORIES "${Python3_INCLUDE_DIRS}"
  SWIG_GENERATED_COMPILE_OPTIONS $<$<CXX_COMPILER_ID:MSVC>:/bigobj>
  INSTALL_RPATH $<$<BOOL:${SKBUILD}>:$<$<PLATFORM_ID:Linux>:$ORIGIN>$<$<PLATFORM_ID:Darwin>:@loader_path>>)
target_link_options(example PUBLIC
  $<$<CXX_COMPILER_ID:AppleClang>:-undefined dynamic_lookup>
  $<$<CXX_COMPILER_ID:Clang,GNU>:-Wl,--unresolved-symbols=ignore-all>
  $<$<CXX_COMPILER_ID:MSVC>:/NODEFAULTLIB:python3${Python3_VERSION_MINOR}.lib /DEFAULTLIB:python3.lib /FORCE:UNRESOLVED>)

install(TARGETS example DESTINATION .)
install(TARGETS example_c DESTINATION .)
