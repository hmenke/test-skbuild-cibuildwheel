find_package(GSL REQUIRED)

add_library(example_c SHARED example.cpp example.hpp)
target_compile_features(example_c PRIVATE cxx_std_17)
target_include_directories(example_c PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
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
set(UseSWIG_MODULE_VERSION 1)

set_property(SOURCE example.i PROPERTY CPLUSPLUS ON)
swig_add_library(example LANGUAGE python SOURCES example.i)
target_compile_features(example PRIVATE cxx_std_17)
set_target_properties(example PROPERTIES
  CXX_EXTENSIONS OFF
  SWIG_COMPILE_OPTIONS "-Wall;-py3"
  SWIG_USE_TARGET_INCLUDE_DIRECTORIES ON
  SWIG_GENERATED_INCLUDE_DIRECTORIES "${Python3_INCLUDE_DIRS}"
  SWIG_GENERATED_COMPILE_OPTIONS $<$<CXX_COMPILER_ID:MSVC>:/bigobj>
  INSTALL_RPATH $<$<BOOL:${SKBUILD}>:$<$<PLATFORM_ID:Linux>:$ORIGIN>$<$<PLATFORM_ID:Darwin>:@loader_path>>)
target_link_options(example PUBLIC
  $<$<CXX_COMPILER_ID:AppleClang>:-undefined dynamic_lookup>
  $<$<CXX_COMPILER_ID:Clang,GNU>:-Wl,--unresolved-symbols=ignore-all>
  $<$<CXX_COMPILER_ID:MSVC>:/NODEFAULTLIB:python3${Python3_VERSION_MINOR}.lib /DEFAULTLIB:python3.lib /FORCE:UNRESOLVED>)
target_link_libraries(example PUBLIC example_c $<$<CXX_COMPILER_ID:MSVC>:${Python3_LIBRARIES_GENERALIZED}>)

install(TARGETS example DESTINATION .)
install(TARGETS example_c DESTINATION .)
