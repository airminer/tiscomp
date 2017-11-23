#include <stdio.h>
#include <stdlib.h>
#include <lua.hpp>

enum TIS_TILE {
	TILE_COMPUTE = 1000,
	TILE_MEMORY = 1001,
	TILE_DAMAGED = 1002,
	TILE_JOURNAL = 1003
};

void setnil(lua_State *L, const char* s) {
	lua_pushnil(L);
	lua_setfield(L, -2, s);
}

void setint(lua_State *L, const char* s, lua_Integer i) {
	lua_pushinteger(L, i);
	lua_setfield(L, -2, s);
}

int main(int argc, char* argv[]) {
	char* file;

	if (argc < 2) {
		fprintf(stderr, "No file provided.\n");
		fprintf(stderr, "Usage: tiscomp FILE\n");
		exit(1);
	} else {
		file = argv[1];
	}

	lua_State *L;

	L = luaL_newstate();

	//luaL_openlibs(L);

	lua_checkstack(L, 7);

	//Base library
	luaL_requiref(L, "base", luaopen_base, false);

	setnil(L, "dofile");
	setnil(L, "load");
	setnil(L, "loadfile");
	setnil(L, "loadstring");
	setnil(L, "getmetatable");
	setnil(L, "setmetatable");
	setnil(L, "rawequal");
	setnil(L, "rawget");
	setnil(L, "rawset");
	setnil(L, "rawlen");
	setnil(L, "pcall");
	setnil(L, "xpcall");

	//package.loaded
	lua_createtable(L, 0, 1);
	lua_createtable(L, 0, 4);

	//string
	lua_pushstring(L, "string");

	if (luaL_loadstring(L,
		"local s = {};"
		"for k,v in pairs(...) do;"
			"s[k] = function(...);"
				"print(\"WARN: string.\"..k..\"() called!\");"
				"s[k] = v;"
				"return v(...);"
			"end;"
		"end;"
		"string = s;"
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

	//set metatble for strings
	lua_getmetatable(L, -2);
	lua_pushvalue(L, -2);
	lua_setfield(L, -2, "__index");
	lua_remove(L, -1);

	lua_settable(L, -3);

	//table
	luaL_requiref(L, "table", luaopen_table, true);

	//Moonsharp alias
	lua_getfield(L, -1, "pack");
	lua_setfield(L, -5, "pack");

	lua_setfield(L, -2, "table");

	//math
	luaL_requiref(L, "math", luaopen_math, true);
	lua_setfield(L, -2, "math");

	//bit32
	luaL_requiref(L, "bit32", luaopen_bit32, true);
	lua_setfield(L, -2, "bit32");

	lua_setfield(L, -2, "loaded");
	lua_setfield(L, -2, "package");

	//TIS-100 constants
	setint(L, "TILE_COMPUTE", TILE_COMPUTE);
	setint(L, "TILE_MEMORY", TILE_MEMORY);
	setint(L, "TILE_DAMAGED", TILE_DAMAGED);
	setint(L, "TILE_JOURNAL", TILE_JOURNAL);
	setint(L, "STREAM_INPUT", 2000);
	setint(L, "STREAM_OUTPUT", 2001);
	setint(L, "STREAM_IMAGE", 2002);

	if (luaL_loadfile(L, file)) {
		fprintf(stderr, "Couldn't load file: %s\n", lua_tostring(L, -1));
		exit(1);
	}

	if (lua_pcall(L, 0, 0, 0)) {
		fprintf(stderr, "Failed to run script: %s\n", lua_tostring(L, -1));
		exit(1);
	}

	lua_getfield(L, -1, "get_layout");
	if(lua_pcall(L, 0, 1, 0)) {
		fprintf(stderr, "Failed to call get_layout(): %s\n", lua_tostring(L, -1));
		exit(1);
	}

	if (!lua_istable(L, -1)) {
		fprintf(stderr, "Failed to get layout: get_layout() returned a value of type %s\n", lua_typename(L, lua_type(L, -1)));
		exit(1);
	}

	size_t l;

	if ((l = lua_rawlen(L, -1)) != 12) {
		fprintf(stderr, "Failed to get layout: get_layout() returned a table of length %d\n", l);
		exit(1);
	}

	int c = 0;
	lua_Integer compute[12];
	int m = 0;
	lua_Integer memory[12];

	for (int i = 1; i <= 12; i++) {
		lua_rawgeti(L, -1, i);
		if (!lua_isnumber(L, -1)) {
			fprintf(stderr, "Failed to get layout: element %d of get_layout() is of type %s\n", i, lua_typename(L, lua_type(L, -1)));
			exit(1);
		}
		lua_Integer tile = lua_tointeger(L, -1);
		lua_remove(L, -1);

		if (tile < TILE_COMPUTE || tile > TILE_JOURNAL) {
			fprintf(stderr, "Failed to get layout: element %d of get_layout() is not a valid tile value(%d)\n", i, tile);
			exit(1);
		}

		switch (tile) {
		case TILE_COMPUTE:
			compute[c++] = i; break;
		case TILE_MEMORY:
			memory[m++] = i; break;
		}
	}

	lua_settop(L, 0);

	if (c > 0) {
		printf("Compute tiles:\n0:%d", compute[0]);
		for (int i = 1; i < c; i++) {
			printf(" %d:%d", i, compute[i]);
		}
		printf("\n");
	}

	if (m > 0) {
		printf("Memory tiles:\n%d", memory[0]);
		for (int i = 1; i < m; i++) {
			printf(" %d", memory[i]);
		}
		printf("\n");
	}

    return 0;
}
