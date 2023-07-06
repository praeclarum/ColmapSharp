CCSRC=$(filter-out %/warp.cc, $(filter-out %_test.cc, $(wildcard colmap-3.8/src/base/*.cc))) \
      $(filter-out %/cudacc.cc, $(filter-out %/cuda.cc, $(filter-out %_test.cc, $(wildcard colmap-3.8/src/util/*.cc))))
CPPSRC=$(wildcard boost-1.64.0/libs/program_options/src/*.cpp) \
       $(wildcard boost-1.64.0/libs/filesystem/src/*.cpp) \
       $(wildcard boost-1.64.0/libs/system/src/*.cpp)	   
CSRC=colmap-3.8/lib/LSD/lsd.c

CXX=clang++
CC=clang
CFLAGS=-fPIC -O3 \
	-Icolmap-3.8/src -Icolmap-3.8/lib -Ieigen-3.3.7 -Iceres-solver-2.1.0/include -Iceres-solver-2.1.0/internal/ceres/miniglog -Iboost-1.64.0 -Imetis-5.2.1/include -Ifreeimage/Source \
	-DIDXTYPEWIDTH=32 -DREALTYPEWIDTH=32
CXXFLAGS=-std=c++14 -frtti -fexceptions $(CFLAGS)
LDFLAGS=-lsqlite3

MACCAT_SYSROOT=$(shell xcrun --sdk macosx --show-sdk-path)
MAC_SYSROOT=$(shell xcrun --sdk macosx --show-sdk-path)
IOS_SYSROOT=$(shell xcrun --sdk iphoneos --show-sdk-path)
IOSSIM_SYSROOT=$(shell xcrun --sdk iphonesimulator --show-sdk-path)

IOS_ARM64_OBJS=$(patsubst %.cc,%-ios-arm64.o,$(CCSRC)) $(patsubst %.c,%-ios-arm64.o,$(CSRC)) $(patsubst %.cpp,%-ios-arm64.o,$(CPPSRC))
IOS_ARM64_FLAGS=-isysroot "$(IOS_SYSROOT)" -target arm64-apple-ios10.0

all: lib/ios/arm64/libcolmap.dylib

%-ios-arm64.o: %.cc
	$(CXX) $(CXXFLAGS) $(IOS_ARM64_FLAGS) -c -o $@ $<
%-ios-arm64.o: %.cpp
	$(CXX) $(CXXFLAGS) $(IOS_ARM64_FLAGS) -c -o $@ $<
%-ios-arm64.o: %.c
	$(CC) $(CFLAGS) $(IOS_ARM64_FLAGS) -c -o $@ $<
lib/ios/arm64/libcolmap.dylib: $(IOS_ARM64_OBJS)
	mkdir -p $(dir $@) && rm -f $@
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(IOS_ARM64_FLAGS) -o $@ $^
