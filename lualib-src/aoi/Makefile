all: laoi.so

CC = gcc
CFLAGS = -g3 -O2 -Wall -fPIC --shared
LUA_INCLUDE_DIR = ../../skynet/3rd/lua

laoi.so: aoi.c lua-aoi.c
	$(CC)  $(CFLAGS)  -I$(LUA_INCLUDE_DIR) $(DEFS)  $^ -o $@


clean:
	-rm laoi.so
