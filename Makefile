SRC=$(filter-out %/warp.cc, $(filter-out %/line.cc, $(filter-out %_test.cc, $(wildcard colmap-3.8/src/base/*.cc))))

CC=clang++
CFLAGS=-std=c++14 -frtti -fexceptions -fPIC -O3 \
	-Icolmap-3.8/src -Ieigen-3.3.7 -Iceres-solver-2.1.0/include -Iceres-solver-2.1.0/internal/ceres/miniglog -Iboost-1.64.0 -Imetis-5.2.1/include \
	-DIDXTYPEWIDTH=32 -DREALTYPEWIDTH=32

MACCAT_SYSROOT=$(shell xcrun --sdk macosx --show-sdk-path)
MAC_SYSROOT=$(shell xcrun --sdk macosx --show-sdk-path)
IOS_SYSROOT=$(shell xcrun --sdk iphoneos --show-sdk-path)
IOSSIM_SYSROOT=$(shell xcrun --sdk iphonesimulator --show-sdk-path)

lib/ios/arm64/libcolmap.dylib: $(SRC)
	mkdir -p $(dir $@)
	rm -f $@
	$(CC) $(CFLAGS) -shared -isysroot "$(IOS_SYSROOT)" -target arm64-apple-ios10.0 $(SRC) -o $@
