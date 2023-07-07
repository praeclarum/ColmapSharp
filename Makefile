CCSRC=$(filter-out %_test.cc, $(wildcard colmap-3.8/src/base/*.cc)) \
	$(filter-out %_test.cc, $(wildcard colmap-3.8/src/estimators/*.cc)) \
	$(filter-out %/extraction.cc, $(filter-out %/matching.cc, $(filter-out %/sift.cc, $(filter-out %_test.cc, $(wildcard colmap-3.8/src/feature/*.cc))))) \
	$(filter-out %_test.cc, $(wildcard colmap-3.8/src/optim/*.cc)) \
	$(filter-out %/option_manager.cc, $(filter-out %/cudacc.cc, $(filter-out %/cuda.cc, $(filter-out %_test.cc, $(wildcard colmap-3.8/src/util/*.cc))))) \
	$(wildcard ceres-solver-2.1.0/internal/ceres/miniglog/glog/*.cc) \
	$(filter-out %_benchmark.cc, $(filter-out %test_utils.cc, $(filter-out %/test_util.cc, $(filter-out %/gmock_main.cc, $(filter-out %/gmock_gtest_all.cc, $(filter-out %_test.cc, $(wildcard ceres-solver-2.1.0/internal/ceres/*.cc))))))) \
	$(wildcard ceres-solver-2.1.0/internal/ceres/generated/*.cc)
CPPSRC=$(filter-out %/SparseBundleCU.cpp, $(filter-out %/CuTexImage.cpp, $(wildcard colmap-3.8/lib/PBA/*.cpp))) \
	$(wildcard boost-1.64.0/libs/program_options/src/*.cpp) \
	$(wildcard boost-1.64.0/libs/filesystem/src/*.cpp) \
	$(wildcard boost-1.64.0/libs/system/src/*.cpp) \
	$(filter-out %/J2KHelper.cpp, $(filter-out %/PluginTIFF.cpp, $(filter-out %/PluginG3.cpp, $(filter-out %/PluginRAW.cpp, $(filter-out %/PluginWebP.cpp, $(filter-out %/PluginJP2.cpp, $(filter-out %/PluginJ2K.cpp, $(filter-out %/PluginEXR.cpp, $(filter-out %/PluginJXR.cpp, $(wildcard freeimage/Source/FreeImage/*.cpp)))))))))) \
	$(filter-out %/XTIFF.cpp, $(wildcard freeimage/Source/Metadata/*.cpp)) \
	$(wildcard freeimage/Source/FreeImageToolkit/*.cpp)
CSRC=$(wildcard colmap-3.8/lib/LSD/*.c) \
	$(filter-out %_avx.c, $(filter-out %_sse2.c, $(wildcard colmap-3.8/lib/VLFeat/*.c))) \
	$(wildcard metis-5.2.1/libmetis/*.c) \
	$(wildcard gklib/*.c) \
	$(filter-out %/wrjpgcom.c, $(filter-out %/rdjpgcom.c, $(filter-out %/djpeg.c, $(filter-out %/jpegtran.c, $(filter-out %/ckconfig.c, $(filter-out %/cjpeg.c, $(filter-out %/jmemname.c, $(filter-out %/jmemnobs.c, $(filter-out %/jmemmac.c, $(filter-out %/jmemdos.c, $(filter-out %/ansi2knr.c, $(filter-out %/example.c, $(wildcard freeimage/Source/LibJPEG/*.c))))))))))))) \
	$(filter-out %/pngtest.c, $(wildcard freeimage/Source/LibPNG/*.c))

CXX=clang++
CC=clang
CFLAGS=-fPIC -O3 \
	-Icolmap-3.8/src -Icolmap-3.8/lib \
	-Iceres-solver-2.1.0/include -Iceres-solver-2.1.0/internal/ceres/miniglog -Iceres-solver-2.1.0/internal \
	-Iboost-1.64.0 -Ieigen-3.3.7 -Imetis-5.2.1/include \
	-Iflann-1.9.2 -Ilz4-1.9.4/lib -Igklib \
	-Ifreeimage/Source -Ifreeimage/Source/OpenEXR/Imath \
	-DIDXTYPEWIDTH=32 -DREALTYPEWIDTH=32 \
	-DVL_DISABLE_SSE2 -DVL_DISABLE_AVX \
	-DPBA_NO_GPU \
	-DCERES_NO_EXPORT= -DCERES_NO_CUDA -DCERES_NO_SUITESPARSE -DCERES_NO_CXSPARSE -DCERES_USE_CXX_THREADS \
	-DNO_MKTEMP -DPNG_ARM_NEON_OPT=0
CXXFLAGS=-std=c++14 -frtti -fexceptions $(CFLAGS)
LDFLAGS=-lz -lsqlite3 -framework Accelerate

MACCAT_SYSROOT=$(shell xcrun --sdk macosx --show-sdk-path)
MAC_SYSROOT=$(shell xcrun --sdk macosx --show-sdk-path)
IOS_SYSROOT=$(shell xcrun --sdk iphoneos --show-sdk-path)
IOSSIM_SYSROOT=$(shell xcrun --sdk iphonesimulator --show-sdk-path)

IOS_ARM64_OBJS=$(patsubst %.cc,%-ios-arm64.o,$(CCSRC)) $(patsubst %.c,%-ios-arm64.o,$(CSRC)) $(patsubst %.cpp,%-ios-arm64.o,$(CPPSRC))
IOS_ARM64_FLAGS=-isysroot "$(IOS_SYSROOT)" -target arm64-apple-ios10.0

all: lib/ios/arm64/libcolmap.dylib

clean:
	rm -rf lib
	rm -f $(IOS_ARM64_OBJS)

%-ios-arm64.o: %.cc
	$(CXX) $(CXXFLAGS) $(IOS_ARM64_FLAGS) -c -o $@ $<
%-ios-arm64.o: %.cpp
	$(CXX) $(CXXFLAGS) $(IOS_ARM64_FLAGS) -c -o $@ $<
%-ios-arm64.o: %.c
	$(CC) $(CFLAGS) $(IOS_ARM64_FLAGS) -c -o $@ $<
lib/ios/arm64/libcolmap.dylib: $(IOS_ARM64_OBJS)
	mkdir -p $(dir $@) && rm -f $@
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(IOS_ARM64_FLAGS) -o $@ $^
