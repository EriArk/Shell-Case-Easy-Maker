cmake_minimum_required(VERSION 3.14)

project(shell_case_occt_worker_native_stub LANGUAGES CXX)

add_executable(occt_worker_native_stub
  src/main.cpp
)

target_compile_features(occt_worker_native_stub PRIVATE cxx_std_17)

if(MSVC)
  target_compile_options(occt_worker_native_stub PRIVATE /W4 /WX /EHsc)
  target_compile_definitions(occt_worker_native_stub PRIVATE NOMINMAX)
else()
  target_compile_options(occt_worker_native_stub PRIVATE -Wall -Wextra -Werror)
endif()
