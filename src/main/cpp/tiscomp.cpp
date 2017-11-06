#include <iostream>
#include <stdio.h>
#include <lua.hpp>

int main()
{
	lua_State *L;

	L = luaL_newstate();

	//luaL_openlibs(L);

	//Base library
	luaL_requiref(L, "base", luaopen_base, false);

	lua_pushstring(L, "dofile");
	lua_pushnil(L);
	lua_settable(L, -3);

	lua_pushstring(L, "load");
	lua_pushnil(L);
	lua_settable(L, -3);

	lua_pushstring(L, "loadfile");
	lua_pushnil(L);
	lua_settable(L, -3);

	lua_pushstring(L, "loadstring");
	lua_pushnil(L);
	lua_settable(L, -3);

	lua_pushstring(L, "getmetatable");
	lua_pushnil(L);
	lua_settable(L, -3);

	lua_pushstring(L, "setmetatable");
	lua_pushnil(L);
	lua_settable(L, -3);

	lua_pushstring(L, "rawequal");
	lua_pushnil(L);
	lua_settable(L, -3);

	lua_pushstring(L, "rawget");
	lua_pushnil(L);
	lua_settable(L, -3);

	lua_pushstring(L, "rawset");
	lua_pushnil(L);
	lua_settable(L, -3);

	lua_pushstring(L, "rawlen");
	lua_pushnil(L);
	lua_settable(L, -3);

	lua_pushstring(L, "pcall");
	lua_pushnil(L);
	lua_settable(L, -3);

	lua_pushstring(L, "xpcall");
	lua_pushnil(L);
	lua_settable(L, -3);

	//package.loaded
	lua_pushstring(L, "package");
	lua_createtable(L, 0, 1);
	lua_pushstring(L, "loaded");
	lua_createtable(L, 0, 4);

	//Other packages
	lua_pushstring(L, "string");

	if (luaL_loadstring(L,
		"string = {};"
		"for k,v in pairs(...) do;"
			"string[k] = function(...);"
				"print(\"WARN: string.\"..k..\"() called!\");"
				"string[k] = v;"
				"return v(...);"
			"end;"
		"end;"
		"return string;"
	)) {
		fprintf(stderr, "Couldn't load string: %s\n", lua_tostring(L, -1));
		exit(1);
	}

	luaL_requiref(L, "string", luaopen_string, false);

	if (lua_pcall(L, 1, 1, 0)) {
		fprintf(stderr, "Failed to run script: %s\n", lua_tostring(L, -1));
		exit(1);
	}

	lua_getmetatable(L, -2);
	lua_pushstring(L, "__index");
	lua_pushvalue(L, -3);
	lua_settable(L, -3);
	lua_remove(L, -1);
	lua_settable(L, -3);

	lua_pushstring(L, "table");
	luaL_requiref(L, "table", luaopen_table, true);

	//Moonsharp alias
	lua_pushstring(L, "pack");
	lua_pushvalue(L, -1);
	lua_gettable(L, -3);
	lua_settable(L, -9);

	lua_settable(L, -3);


	lua_pushstring(L, "math");
	luaL_requiref(L, "math", luaopen_math, true);
	lua_settable(L, -3);

	lua_pushstring(L, "bit32");
	luaL_requiref(L, "bit32", luaopen_bit32, true);
	lua_settable(L, -3);

	lua_settable(L, -3);
	lua_settable(L, -3);

	lua_settop(L, 0);

	if (luaL_loadfile(L, "test.lua")) {
		fprintf(stderr, "Couldn't load file: %s\n", lua_tostring(L, -1));
		exit(1);
	}

	if (lua_pcall(L, 0, LUA_MULTRET, 0)) {
		fprintf(stderr, "Failed to run script: %s\n", lua_tostring(L, -1));
		exit(1);
	}

    return 0;
}

