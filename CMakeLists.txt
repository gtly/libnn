cmake_minimum_required(VERSION 3.0)

# 定义目标系统
set(CMAKE_SYSTEM_NAME Generic)  # 裸机系统使用 Generic，Linux 系统用 Linux
set(CMAKE_SYSTEM_PROCESSOR riscv)

# 指定交叉编译器路径（需替换为你的实际安装路径）

set(GNURISCV_TOOLCHAIN_PATH "/opt/zcc-toolchain/3.2.5")
set(CMAKE_C_COMPILER "zcc")





project(libnn C)




include_directories(${PROJECT_SOURCE_DIR}/Include
${PROJECT_SOURCE_DIR}/internal
)
file(GLOB_RECURSE LIB_SRCS "${CMAKE_CURRENT_SOURCE_DIR}/Source/*.c")
file(GLOB APP_SRCS "${CMAKE_CURRENT_SOURCE_DIR}/example/*.c")
MESSAGE( STATUS "${LIB_SRCS}.")
MESSAGE( STATUS "${APP_SRCS}.")

message( STATUS "${CMAKE_C_COMPILER}")
message(STATUS "头文件路径: ${PROJECT_SOURCE_DIR}/include")
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/build)


add_library(test STATIC ${LIB_SRCS})
  


target_link_libraries(test m)   


add_executable(app ${APP_SRCS})

target_link_libraries(app test) 

# 定义可执行目标

add_custom_command(
    TARGET app POST_BUILD
    COMMAND llvm-objdump
        -d          # 反汇编代码段
        -S          # 混合显示源码和汇编（需编译时加 -g）
        $<TARGET_FILE:app> > app.objdump
    COMMENT "Generating RISC-V objdump file: app.objdump"
)