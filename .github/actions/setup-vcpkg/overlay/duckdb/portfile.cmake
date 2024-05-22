vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO duckdb/duckdb
  REF "v${VERSION}"
  SHA512 2f22f1308c8438df53a05764288a35871459b5c9cc65731c369932133d7372a046ed50dcdbcdf137e783e9e72afdc00785efe8418e6c4371b18e84774fa0b050
  HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    threads DISABLE_THREADS
)

set(AVAILABLE_EXTENSIONS "autocomplete;fts;httpfs;icu;inet;json;parquet;sqlsmith;tpcds;tpch")
foreach(EXTENSION ${AVAILABLE_EXTENSIONS})
  if(${EXTENSION} IN_LIST FEATURES)
    list(APPEND BUILD_EXTENSIONS "${EXTENSION}")
  endif()
endforeach()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DOVERRIDE_GIT_DESCRIBE:STRING="v${VERSION}"
    -DBUILD_UNITTESTS:BOOL=OFF
    -DBUILD_SHELL:BOOL=FALSE
    -DENABLE_SANITIZER:BOOL=OFF
    -DENABLE_THREAD_SANITIZER:BOOL=OFF
    -DENABLE_UBSAN:BOOL=OFF
    -DBUILD_EXTENSIONS="${BUILD_EXTENSIONS}"
    ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/DuckDB")
  vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/DuckDB")
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/duckdb")
  vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/duckdb")
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/DuckDBConfig.cmake"
[[set(DuckDB_INCLUDE_DIRS "${DuckDB_CMAKE_DIR}/../../../include")]]
[[get_filename_component(DuckDB_INCLUDE_DIRS "${DuckDB_CMAKE_DIR}" PATH)
get_filename_component(DuckDB_INCLUDE_DIRS "${DuckDB_INCLUDE_DIRS}" PATH)
set(DuckDB_INCLUDE_DIRS "${DuckDB_INCLUDE_DIRS}/include")]])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/duckdb/storage/serialization")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
