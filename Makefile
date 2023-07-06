SRC=$(filter-out %/warp.cc, $(filter-out %_test.cc, $(wildcard colmap-3.8/src/base/*.cc))) \
	$(filter-out %/cudacc.cc, $(filter-out %/cuda.cc, $(filter-out %_test.cc, $(wildcard colmap-3.8/src/util/*.cc))))

CC=clang++
CFLAGS=-std=c++14 -frtti -fexceptions -fPIC -O3 \
	-Icolmap-3.8/src -Icolmap-3.8/lib -Ieigen-3.3.7 -Iceres-solver-2.1.0/include -Iceres-solver-2.1.0/internal/ceres/miniglog -Iboost-1.64.0 -Imetis-5.2.1/include -Ifreeimage/Source \
	-DIDXTYPEWIDTH=32 -DREALTYPEWIDTH=32
LDFLAGS=-lsqlite3

MACCAT_SYSROOT=$(shell xcrun --sdk macosx --show-sdk-path)
MAC_SYSROOT=$(shell xcrun --sdk macosx --show-sdk-path)
IOS_SYSROOT=$(shell xcrun --sdk iphoneos --show-sdk-path)
IOSSIM_SYSROOT=$(shell xcrun --sdk iphonesimulator --show-sdk-path)

IOS_ARM64_OBJS=$(patsubst %.cc,%-ios-arm64.o,$(SRC))
IOS_ARM64_FLAGS=-isysroot "$(IOS_SYSROOT)" -target arm64-apple-ios10.0

all: lib/ios/arm64/libcolmap.dylib

%-ios-arm64.o: %.cc Makefile
	$(CC) $(CFLAGS) $(IOS_ARM64_FLAGS) -c -o $@ $<
lib/ios/arm64/libcolmap.dylib: $(IOS_ARM64_OBJS)
	mkdir -p $(dir $@) && rm -f $@
	$(CC) $(CFLAGS) $(LDFLAGS) $(IOS_ARM64_FLAGS) -o $@ $^
