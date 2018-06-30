SRC=pb.c

TARGET=pb.so
CFLAGS=`pkg-config --cflags lua5.3` -std=gnu99
LDFLAGS=`pkg-config --libs lua5.3`

all:$(TARGET)

$(TARGET):$(SRC)
	gcc -O3 -shared -fPIC -I../../skynet/3rd/lua $(SRC) $(CFLAGS) $(LDFLAGS) -o $@
