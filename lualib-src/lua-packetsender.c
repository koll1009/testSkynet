// simple lua socket library for client
// It's only for demo, limited feature. Don't use it in your project.
// Rewrite socket library by yourself .

#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>
#include <string.h>
#include <stdint.h>
#include <pthread.h>
#include <stdlib.h>

#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>

#define CACHE_SIZE 0x1000	

static int
lSendRequest(lua_State *L) {
	int proto = luaL_checkinteger(L, 1);
	size_t sz = 0;
	const char * bytes = luaL_checkstring(L, 2, &sz);
	printf("%d, %d\n", proto, sz);
	return 1;
}

LUAMOD_API int
luaopen_mmocore_packetsender(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "SendRequest", lSendRequest },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);

	return 1;
}
