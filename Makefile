SRC=$(wildcard colmap/src/colmap/base/*.cc)

CC=clang++
CFLAGS=-std=c++14 -fpic -Icolmap/src -Ieigen-3.3.7 -Iceres-solver-2.1.0/include

%.o: %.cc
	$(CC) $(CFLAGS) -c -o $@ $<

colmap-ios-arm7.a: $(SRC:.cc=.o)
	$(AR) rcs $@ $^
