#CC=${CROSS_COMPILE}clang
CC=zcc
AS=as
AR=ar
OBJDUMP=/opt/zcc-toolchain/3.2.5/bin/llvm-objdump
RANLIB=ranlib
OBJCOPY=objcopy
SZ=size
RUN=run

LIB_NAME=libnn

VERSION =
SO_VERSION =

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
LIB_ROOT := $(shell dirname $(MKFILE_PATH))/zcc
LIB_ROOT_PASS := $(shell dirname $(MKFILE_PATH))

INCLUDE_DIR := -I${LIB_ROOT_PASS}/Include -I${LIB_ROOT_PASS}/internal
CFLAGS += -I$(RISCV_SYSROOT)/include

# source code root path
SRC_ROOT := $(LIB_ROOT_PASS)/Source

# folders of all category function
SRC_DIR := $(addprefix $(SRC_ROOT)/, ActivationFunctions \
									 BasicFunctions \
									 ConcatenationFunctions \
									 ConvolutionFunctions \
									 FullyConnectedFunctions \
									 NNSupportFunctions \
									 PoolingFunctions \
									 SoftmaxFunctions \
									 UtilFunctions)
# for nds_version.c
SRC_DIR += $(LIB_ROOT)

# the folder to keep output objects
BUILD := ${LIB_ROOT}/lib_objs

# source file searching paths
VPATH := $(SRC_DIR)

# all source file list
SRCS := $(foreach DIR,$(SRC_DIR),$(patsubst $(DIR)/%,%,$(wildcard $(DIR)/*.c)))

# remove the f16 related source files as the toolchain doesn't support zfh extension
ifeq (,$(findstring -mzfh,$(CFLAGS)))
	F16_SRCS := $(foreach DIR,$(SRC_DIR),$(patsubst $(DIR)/%,%,$(wildcard $(DIR)/*f16*.c)))
	SRCS := $(filter-out $(F16_SRCS),$(SRCS))
endif

# object list
OBJS := $(addprefix $(BUILD)/,$(SRCS:.c=.o))

.PHONY: all clean

# 定义根目录和构建目录（取消末尾的重新定义）



all: $(OBJS)
	@echo
	@echo '*** Build Andes NN library ***'
	$(AR) crD $(LIB_ROOT)/$(LIB_NAME).a $(OBJS)
	$(RANLIB) -D $(LIB_ROOT)/$(LIB_NAME).a
	@echo '*** Build Andes NN Library complete ^_^ ***'
	${OBJDUMP} -S $(LIB_ROOT)/$(LIB_NAME).a > $(LIB_ROOT)/$(LIB_NAME).a.objdump
	@echo

$(BUILD)/%.o : %.c | $(BUILD)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(LIB_ROOT)/*.a $(LIB_ROOT)/*.objdump $(BUILD)
	@echo 'clean done'
