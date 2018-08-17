#include <lua.h>
#include <lauxlib.h>
#include "bTask.h"

static int _create(lua_State *L) 
{
	bTask test;
	//struct laoi_space *lspace = malloc(sizeof(*lspace));
	//lspace->cookie = malloc(sizeof(struct laoi_cookie));
	//lspace->cookie->count = 0;
	//lspace->cookie->max = 0;
	//lspace->cookie->current = 0;
	//lspace->space = aoi_create(aoi_alloc, lspace->cookie);

	//lua_rawsetp(L, LUA_REGISTRYINDEX, aoi_cb_message);

	//lua_pushlightuserdata(L, lspace);
	return 1;
}

int luaopen_bTree(lua_State *L) {
	luaL_checkversion(L);

	luaL_Reg l[] = {
	{ "create", _create },
	/*{ "update", _aoi_update },
	{ "message", _aoi_message },
	{ "release", _aoi_release },
	{ "dump", _aoi_dump },*/
	{ NULL, NULL },
	};

	luaL_newlib(L, l);

	return 1;
}