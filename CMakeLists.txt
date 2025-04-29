cmake_minimum_required(VERSION 3.0)

# 定义目标系统
set(CMAKE_SYSTEM_NAME Generic)  # 裸机系统使用 Generic，Linux 系统用 Linux
set(CMAKE_SYSTEM_PROCESSOR riscv)

# 指定交叉编译器路径（需替换为你的实际安装路径）
set(TOOLCHAIN_PATH "/opt/riscv/bin")
set(CMAKE_C_COMPILER "${TOOLCHAIN_PATH}/riscv64-unknown-elf-gcc")
set(CMAKE_CXX_COMPILER "${TOOLCHAIN_PATH}/riscv64-unknown-elf-g++")

# 设置 ABI 和架构（参考工具链编译参数[1,3,6](@ref)）
# 在 CMake 工具链文件中设置（示例针对 RV64 双浮点）
add_compile_options(-march=rv64gc -mabi=lp64d)

# 目标系统根目录（若使用 newlib 等库）
set(CMAKE_SYSROOT "/opt/riscv/riscv64-unknown-elf")

# 库和头文件搜索规则
set(CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)   # 不搜索主机程序
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)    # 仅搜索目标库
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)    # 仅搜索目标头文件

# 禁用线程支持（newlib 默认不支持）
set(THREADS_PREFER_PTHREAD_FLAG OFF)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)



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
    COMMAND riscv64-unknown-elf-objdump
        -d          # 反汇编代码段
        -S          # 混合显示源码和汇编（需编译时加 -g）
        $<TARGET_FILE:app> > app.objdump
    COMMENT "Generating RISC-V objdump file: app.objdump"
)