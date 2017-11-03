#include <iostream>
#include <stdio.h>
#include <lua.hpp>

int main()
{
	lua_State *L;

	L = luaL_newstate();

	luaL_openlibs(L);

	int status = luaL_loadfile(L, "test.lua");
	if (status) {
		fprintf(stderr, "Couldn't load file: %s\n", lua_tostring(L, -1));
		exit(1);
	}

	int result = lua_pcall(L, 0, LUA_MULTRET, 0);
	if (result) {
		fprintf(stderr, "Failed to run script: %s\n", lua_tostring(L, -1));
		exit(1);
	}

    return 0;
}

