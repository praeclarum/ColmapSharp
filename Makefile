CCSRC=$(filter-out %_test.cc, $(wildcard colmap-3.8/src/base/*.cc)) \
	$(filter-out %_test.cc, $(wildcard colmap-3.8/src/controllers/*.cc)) \
	$(filter-out %_test.cc, $(wildcard colmap-3.8/src/estimators/*.cc)) \
	$(filter-out %_test.cc, $(wildcard colmap-3.8/src/feature/*.cc)) \
	$(filter-out %_test.cc, $(wildcard colmap-3.8/src/optim/*.cc)) \
	$(filter-out %_test.cc, $(wildcard colmap-3.8/src/retrieval/*.cc)) \
	$(filter-out %_test.cc, $(wildcard colmap-3.8/src/sfm/*.cc)) \
	$(filter-out %/cudacc.cc, $(filter-out %/cuda.cc, $(filter-out %_test.cc, $(wildcard colmap-3.8/src/util/*.cc)))) \
	$(wildcard ceres-solver-2.1.0/internal/ceres/miniglog/glog/*.cc) \
	$(filter-out %_benchmark.cc, $(filter-out %test_utils.cc, $(filter-out %/test_util.cc, $(filter-out %/gmock_main.cc, $(filter-out %/gmock_gtest_all.cc, $(filter-out %_test.cc, $(wildcard ceres-solver-2.1.0/internal/ceres/*.cc))))))) \
	$(wildcard ceres-solver-2.1.0/internal/ceres/generated/*.cc)
CPPSRC=$(filter-out %/SparseBundleCU.cpp, $(filter-out %/CuTexImage.cpp, $(wildcard colmap-3.8/lib/PBA/*.cpp))) \
	$(wildcard boost-1.64.0/libs/program_options/src/*.cpp) \
	$(wildcard boost-1.64.0/libs/filesystem/src/*.cpp) \
	$(wildcard boost-1.64.0/libs/system/src/*.cpp) \
	$(filter-out %/J2KHelper.cpp, $(filter-out %/PluginTIFF.cpp, $(filter-out %/PluginG3.cpp, $(filter-out %/PluginRAW.cpp, $(filter-out %/PluginWebP.cpp, $(filter-out %/PluginJP2.cpp, $(filter-out %/PluginJ2K.cpp, $(filter-out %/PluginEXR.cpp, $(filter-out %/PluginJXR.cpp, $(wildcard freeimage/Source/FreeImage/*.cpp)))))))))) \
	$(filter-out %/XTIFF.cpp, $(wildcard freeimage/Source/Metadata/*.cpp)) \
	$(wildcard freeimage/Source/FreeImageToolkit/*.cpp) \
	$(wildcard src/*.cpp)
CSRC=$(wildcard colmap-3.8/lib/LSD/*.c) \
	$(filter-out %_avx.c, $(filter-out %_sse2.c, $(wildcard colmap-3.8/lib/VLFeat/*.c))) \
	$(wildcard metis-5.2.1/libmetis/*.c) \
	$(wildcard gklib/*.c) \
	$(wildcard lz4-1.9.4/lib/*.c) \
	$(filter-out %/wrjpgcom.c, $(filter-out %/rdjpgcom.c, $(filter-out %/djpeg.c, $(filter-out %/jpegtran.c, $(filter-out %/ckconfig.c, $(filter-out %/cjpeg.c, $(filter-out %/jmemname.c, $(filter-out %/jmemnobs.c, $(filter-out %/jmemmac.c, $(filter-out %/jmemdos.c, $(filter-out %/ansi2knr.c, $(filter-out %/example.c, $(wildcard freeimage/Source/LibJPEG/*.c))))))))))))) \
	$(filter-out %/pngtest.c, $(wildcard freeimage/Source/LibPNG/*.c))
CLI_SRC=$(wildcard cli/*.cpp)

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
LDFLAGS=-dynamiclib -current_version 1.0 -compatibility_version 1.0 -fvisibility=hidden \
	-lz -lsqlite3 -framework Accelerate

MACCAT_SYSROOT=$(shell xcrun --sdk macosx --show-sdk-path)
MAC_SYSROOT=$(shell xcrun --sdk macosx --show-sdk-path)
IOS_SYSROOT=$(shell xcrun --sdk iphoneos --show-sdk-path)
IOSSIM_SYSROOT=$(shell xcrun --sdk iphonesimulator --show-sdk-path)

IOS_ARM64_OBJS=$(patsubst %.cc,%-ios-arm64.o,$(CCSRC)) $(patsubst %.c,%-ios-arm64.o,$(CSRC)) $(patsubst %.cpp,%-ios-arm64.o,$(CPPSRC))
IOS_ARM64_FLAGS=-isysroot "$(IOS_SYSROOT)" -target arm64-apple-ios10.0 -mios-version-min=10.0

IOSSIM_X64_OBJS=$(patsubst %.cc,%-iossim-x86_64.o,$(CCSRC)) $(patsubst %.c,%-iossim-x86_64.o,$(CSRC)) $(patsubst %.cpp,%-iossim-x86_64.o,$(CPPSRC))
IOSSIM_X64_FLAGS=-isysroot "$(IOSSIM_SYSROOT)" -target x86_64-apple-iossim10.0 -mios-version-min=10.0

MACCAT_X64_OBJS=$(patsubst %.cc,%-maccat-x86_64.o,$(CCSRC)) $(patsubst %.c,%-maccat-x86_64.o,$(CSRC)) $(patsubst %.cpp,%-maccat-x86_64.o,$(CPPSRC))
MACCAT_X64_FLAGS=-isysroot "$(MACCAT_SYSROOT)" -target x86_64-apple-ios13.1-macabi -mios-version-min=13.1

MAC_X64_OBJS=$(patsubst %.cc,%-mac-x86_64.o,$(CCSRC)) $(patsubst %.c,%-mac-x86_64.o,$(CSRC)) $(patsubst %.cpp,%-mac-x86_64.o,$(CPPSRC))
MAC_X64_FLAGS=-isysroot "$(MAC_SYSROOT)" -target x86_64-apple-darwin -mmacosx-version-min=11.0

LIBS=lib/ios/arm64/libcolmap.dylib lib/iossim/x86_64/libcolmap.dylib lib/mac/x86_64/libcolmap.dylib lib/maccat/x86_64/libcolmap.dylib

ASMS=ColmapSharp/bin/Release/net6.0-ios/ios-arm64/ColmapSharp.dll ColmapSharp/bin/Release/net6.0-ios/iossimulator-x64/ColmapSharp.dll

all: colmap-cli nuget

clean:
	rm -rf lib
	rm -f $(IOS_ARM64_OBJS) $(IOSSIM_X64_OBJS) $(MAC_X64_OBJS) $(MACCAT_X64_OBJS)

colmap-cli: $(CLI_SRC) lib/mac/x86_64/libcolmap.dylib Makefile
	$(CXX) $(CXXFLAGS) -Llib/mac/x86_64 -lcolmap -o $@ $(CLI_SRC)

nuget: Praeclarum.ColmapSharp.nuspec managed
	nuget pack Praeclarum.ColmapSharp.nuspec
	ls -al *.nupkg

managed: $(ASMS)

ColmapSharp/bin/Release/net6.0-ios/ios-arm64/ColmapSharp.dll: ColmapSharp/ColmapSharp.csproj $(CSSRCS) lib/ios/arm64/libcolmap.dylib
	dotnet build -c Release /p:TargetFrameworks=net6.0-ios /p:RuntimeIdentifier=ios-arm64 ColmapSharp/ColmapSharp.csproj

ColmapSharp/bin/Release/net6.0-ios/iossimulator-x64/ColmapSharp.dll: ColmapSharp/ColmapSharp.csproj $(CSSRCS) lib/iossimulator/x86_64/libcolmap.dylib
	dotnet build -c Release /p:TargetFrameworks=net6.0-ios /p:RuntimeIdentifier=iossimulator-x64 ColmapSharp/ColmapSharp.csproj

ColmapSharp/bin/Release/net6.0-maccatalyst/maccatalyst-x64/ColmapSharp.dll: ColmapSharp/ColmapSharp.csproj $(CSSRCS) lib/maccat/x86_64/libcolmap.dylib
	dotnet build -c Release /p:TargetFrameworks=net6.0-maccatalyst /p:RuntimeIdentifier=maccatalyst-x64 ColmapSharp/ColmapSharp.csproj


native: $(LIBS)

%-ios-arm64.o: %.cc
	$(CXX) $(CXXFLAGS) $(IOS_ARM64_FLAGS) -c -o $@ $<
%-ios-arm64.o: %.cpp
	$(CXX) $(CXXFLAGS) $(IOS_ARM64_FLAGS) -c -o $@ $<
%-ios-arm64.o: %.c
	$(CC) $(CFLAGS) $(IOS_ARM64_FLAGS) -c -o $@ $<
lib/ios/arm64/libcolmap.dylib: $(IOS_ARM64_OBJS)
	mkdir -p $(dir $@) && rm -f $@
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(IOS_ARM64_FLAGS) -o $@ $^

%-iossim-x86_64.o: %.cc
	$(CXX) $(CXXFLAGS) -stdlib=libc++ $(IOSSIM_X64_FLAGS) -c -o $@ $<
%-iossim-x86_64.o: %.cpp
	$(CXX) $(CXXFLAGS) -stdlib=libc++ $(IOSSIM_X64_FLAGS) -c -o $@ $<
%-iossim-x86_64.o: %.c
	$(CC) $(CFLAGS) $(IOSSIM_X64_FLAGS) -c -o $@ $<
lib/iossim/x86_64/libcolmap.dylib: $(IOSSIM_X64_OBJS)
	mkdir -p $(dir $@) && rm -f $@
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(IOSSIM_X64_FLAGS) -o $@ $^

%-mac-x86_64.o: %.cc
	$(CXX) $(CXXFLAGS) $(MAC_X64_FLAGS) -c -o $@ $<
%-mac-x86_64.o: %.cpp
	$(CXX) $(CXXFLAGS) $(MAC_X64_FLAGS) -c -o $@ $<
%-mac-x86_64.o: %.c
	$(CC) $(CFLAGS) $(MAC_X64_FLAGS) -c -o $@ $<
lib/mac/x86_64/libcolmap.dylib: $(MAC_X64_OBJS)
	mkdir -p $(dir $@) && rm -f $@
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(MAC_X64_FLAGS) -o $@ $^

%-maccat-x86_64.o: %.cc
	$(CXX) $(CXXFLAGS) $(MACCAT_X64_FLAGS) -c -o $@ $<
%-maccat-x86_64.o: %.cpp
	$(CXX) $(CXXFLAGS) $(MACCAT_X64_FLAGS) -c -o $@ $<
%-maccat-x86_64.o: %.c
	$(CC) $(CFLAGS) $(MACCAT_X64_FLAGS) -c -o $@ $<
lib/maccat/x86_64/libcolmap.dylib: $(MACCAT_X64_OBJS)
	mkdir -p $(dir $@) && rm -f $@
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(MACCAT_X64_FLAGS) -o $@ $^
