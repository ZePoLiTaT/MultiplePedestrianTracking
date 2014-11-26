cmake_minimum_required(VERSION 2.8)

find_package(OpenCV REQUIRED)

add_definitions(-DUNICODE -D_UNICODE)
file(GLOB CPP_FILES *.cpp)

add_executable(ZTracker ${CPP_FILES})
target_link_libraries(ZTracker ${OpenCV_LIBS})