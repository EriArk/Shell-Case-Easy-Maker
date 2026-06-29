cmake_minimum_required(VERSION 3.14)

project(shell_case_occt_worker_native LANGUAGES CXX)

option(SHELL_CASE_ENABLE_OCCT "Build the opt-in OCCT-linked native worker target" OFF)

function(shell_case_configure_native_target target_name)
  target_compile_features(${target_name} PRIVATE cxx_std_17)

  if(MSVC)
    target_compile_options(${target_name} PRIVATE /W4 /WX /EHsc)
    target_compile_definitions(${target_name} PRIVATE NOMINMAX)
  else()
    target_compile_options(${target_name} PRIVATE -Wall -Wextra -Werror)
  endif()
endfunction()

add_executable(occt_worker_native_stub
  src/main.cpp
)
shell_case_configure_native_target(occt_worker_native_stub)

if(SHELL_CASE_ENABLE_OCCT)
  find_package(OpenCASCADE CONFIG REQUIRED)

  add_executable(occt_worker_native_occt
    src/occt_main.cpp
  )
  shell_case_configure_native_target(occt_worker_native_occt)
  target_compile_definitions(occt_worker_native_occt PRIVATE SHELL_CASE_ENABLE_OCCT=1)

  if(OpenCASCADE_INCLUDE_DIR)
    target_include_directories(occt_worker_native_occt PRIVATE ${OpenCASCADE_INCLUDE_DIR})
  elseif(OpenCASCADE_INCLUDE_DIRS)
    target_include_directories(occt_worker_native_occt PRIVATE ${OpenCASCADE_INCLUDE_DIRS})
  endif()

  if(NOT OpenCASCADE_LIBRARIES)
    message(FATAL_ERROR "OpenCASCADEConfig.cmake was found, but OpenCASCADE_LIBRARIES is empty.")
  endif()

  target_link_libraries(occt_worker_native_occt PRIVATE ${OpenCASCADE_LIBRARIES})
endif()
