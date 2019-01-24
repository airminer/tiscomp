#include <stdlib.h>
#include <lua.hpp>

#include "save.hpp"
#include "puzzle.hpp"

Stream::Stream(const int type) : type(type) {}

Puzzle::Puzzle() : inStreams(4, Stream(STREAM_INPUT)),
                   outStreams(4, Stream(STREAM_OUTPUT)) {}

void setnil(lua_State *L, const char* s) {
	lua_pushnil(L);
	lua_setfield(L, -2, s);
}

void setint(lua_State *L, const char* s, lua_Integer i) {
	lua_pushinteger(L, i);
	lua_setfield(L, -2, s);
}

Puzzle puzzle_parser(const char* file) {
	Puzzle ret;
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
	setint(L, "STREAM_INPUT", STREAM_INPUT);
	setint(L, "STREAM_OUTPUT", STREAM_OUTPUT);
	setint(L, "STREAM_IMAGE", STREAM_IMAGE);

	if (luaL_loadfile(L, file)) {
		fprintf(stderr, "Couldn't load file: %s\n", lua_tostring(L, -1));
		exit(1);
	}

	if (lua_pcall(L, 0, 0, 0)) {
		fprintf(stderr, "Failed to run script: %s\n", lua_tostring(L, -1));
		exit(1);
	}

	lua_getfield(L, -1, "get_layout");
	if (lua_pcall(L, 0, 1, 0)) {
		fprintf(stderr, "Failed to call get_layout(): %s\n", lua_tostring(L, -1));
		exit(1);
	}

	if (!lua_istable(L, -1)) {
		fprintf(stderr, "Failed to get layout: get_layout() returned a value of type %s\n", lua_typename(L, lua_type(L, -1)));
		exit(1);
	}

	size_t l;

	if ((l = lua_rawlen(L, -1)) != 12) {
		fprintf(stderr, "Failed to get layout: get_layout() returned a table of length %zu\n", l);
		exit(1);
	}

	for (int i = 1; i <= 12; i++) {
		lua_rawgeti(L, -1, i);
		if (!lua_isnumber(L, -1)) {
			fprintf(stderr, "Failed to get layout: element %d of get_layout() is of type %s\n", i, lua_typename(L, lua_type(L, -1)));
			exit(1);
		}
		lua_Integer tile = lua_tointeger(L, -1);
		lua_remove(L, -1);

		if (tile < TILE_COMPUTE || tile > TILE_JOURNAL) {
			fprintf(stderr, "Failed to get layout: element %d of get_layout() is not a valid tile value(%td)\n", i, tile);
			exit(1);
		}

		switch (tile) {
		case TILE_COMPUTE:
			ret.compute.push_back(i - 1); break;
		case TILE_MEMORY:
			ret.memory.push_back(i - 1); break;
		}
	}

	lua_remove(L, -1);

	lua_getfield(L, -1, "get_streams");
	if (lua_pcall(L, 0, 1, 0)) {
		fprintf(stderr, "Failed to call get_streams(): %s\n", lua_tostring(L, -1));
		exit(1);
	}

	if (!lua_istable(L, -1)) {
		fprintf(stderr, "Failed to get layout: get_streams() returned a value of type %s\n", lua_typename(L, lua_type(L, -1)));
		exit(1);
	}

	l = lua_rawlen(L, -1);

	for (int i = 1; (unsigned)i <= l; i++) {
		lua_rawgeti(L, -1, i);
		if (!lua_istable(L, -1)) {
			fprintf(stderr, "Failed to get streams: element %d of get_streams() is of type %s\n", i, lua_typename(L, lua_type(L, -1)));
			exit(1);
		}

		size_t len;

		if ((len = lua_rawlen(L, -1)) != 4) {
			fprintf(stderr, "Failed to get streams: element %d of get_streams() is of length %zu\n", i, len);
			exit(1);
		}

		lua_rawgeti(L, -1, 1);
		if (!lua_isnumber(L, -1)) {
			fprintf(stderr, "Failed to get streams: element 1 of get_streams()[%d] is of type %s\n", i, lua_typename(L, lua_type(L, -1)));
			exit(1);
		}

		lua_Integer type = lua_tointeger(L, -1);
		if (type < STREAM_INPUT || type > STREAM_OUTPUT) {
			fprintf(stderr, "Failed to get streams: element %d of get_streams() is not a valid stream type(%td)\n", i, type);
			exit(1);
		}

		lua_remove(L, -1);

		lua_rawgeti(L, -1, 3);
		if (!lua_isnumber(L, -1)) {
			fprintf(stderr, "Failed to get streams: element 3 of get_streams()[%d] is of type %s\n", i, lua_typename(L, lua_type(L, -1)));
			exit(1);
		}

		lua_Integer pos = lua_tointeger(L, -1);
		if (pos < 0 || pos > 3) {
			fprintf(stderr, "Failed to get streams: element %d of get_streams() is not a valid position(%td)\n", i, pos);
			exit(1);
		}

		lua_remove(L, -1);

		lua_rawgeti(L, -1, 4);
		if (!lua_istable(L, -1)) {
			fprintf(stderr, "Failed to get streams: element 4 of get_streams()[%d] is of type %s\n", i, lua_typename(L, lua_type(L, -1)));
			exit(1);
		}

		len = lua_rawlen(L, -1);
		if (len > 39) {
			fprintf(stderr, "Failed to get streams: element 4 of get_streams()[%d] is longer than 39 elements (%zu)\n", i, len);
			exit(1);
		}

		for (int j = 1; (unsigned)j <= len; j++) {
			lua_rawgeti(L, -1, j);
			if (!lua_isnumber(L, -1)) {
				fprintf(stderr, "Failed to get streams: element %d of get_streams()[%d][4] is of type %s\n", j, i, lua_typename(L, lua_type(L, -1)));
				exit(1);
			}

			lua_Integer val = lua_tointeger(L, -1);
			if (val < -999 || val > 999) {
				fprintf(stderr, "Failed to get streams: element %d of get_streams()[%d][4] is not a valid value(%td)\n", j, i, val);
				exit(1);
			}
			lua_remove(L, -1);

			if (type == STREAM_INPUT) {
				ret.inStreams[pos].data.push_back(val);
			}
			else {
				ret.outStreams[pos].data.push_back(val);
			}
		}

		lua_remove(L, -1);
		lua_remove(L, -1);

	}

	lua_close(L);

	return ret;
}