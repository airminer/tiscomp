#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <lua.hpp>
#include "save.hpp"

extern "C" int yyparse();
extern "C" FILE *yyin;
extern int linenum, yydebug;

extern std::vector<Core*> cores;

void lineerror(int line, const char *s, ...) {
	fprintf(stderr, "Parse error at line %d: ", line);

	va_list argptr;
	va_start(argptr, s);
	vfprintf(stderr, s, argptr);
	va_end(argptr);
}

void yyerror(const char *s, ...) {
	fprintf(stderr, "Parse error at line %d: ", linenum);

	va_list argptr;
	va_start(argptr, s);
	vfprintf(stderr, s, argptr);
	va_end(argptr);

	// might as well halt now:
	exit(1);
}

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

void printsrc(int i) {
	switch(i) {
	case NIL: printf("NIL"); break;
	case ACC: printf("ACC"); break;
	case ANY: printf("ANY"); break;
	case LAST: printf("LAST"); break;
	case UP: printf("UP"); break;
	case RIGHT: printf("RIGHT"); break;
	case DOWN: printf("DOWN"); break;
	case LEFT: printf("LEFT"); break;
	default: printf("%d", i); break;
	}
}

int main(int argc, char* argv[]) {
	char* file;
	char* save;

	if (argc < 3) {
		fprintf(stderr, "Not enough arguments.\n");
		fprintf(stderr, "Usage: tiscomp FILE SAVE\n");
		exit(1);
	} else {
		file = argv[1];
		save = argv[2];
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
		fprintf(stderr, "Failed to get layout: get_layout() returned a table of length %ld\n", l);
		exit(1);
	}

	size_t c = 0;
	int compute[12];
	size_t m = 0;
	int memory[12];

	for (int i = 1; i <= 12; i++) {
		lua_rawgeti(L, -1, i);
		if (!lua_isnumber(L, -1)) {
			fprintf(stderr, "Failed to get layout: element %d of get_layout() is of type %s\n", i, lua_typename(L, lua_type(L, -1)));
			exit(1);
		}
		lua_Integer tile = lua_tointeger(L, -1);
		lua_remove(L, -1);

		if (tile < TILE_COMPUTE || tile > TILE_JOURNAL) {
			fprintf(stderr, "Failed to get layout: element %d of get_layout() is not a valid tile value(%ld)\n", i, tile);
			exit(1);
		}

		switch (tile) {
		case TILE_COMPUTE:
			compute[c++] = i-1; break;
		case TILE_MEMORY:
			memory[m++] = i-1; break;
		}
	}

	lua_settop(L, 0);

	if (c > 0) {
		printf("Compute tiles:\n0:%d", compute[0]);
		for (size_t i = 1; i < c; i++) {
			printf(" %ld:%d", i, compute[i]);
		}
		printf("\n");
	}

	if (m > 0) {
		printf("Memory tiles:\n%d", memory[0]);
		for (size_t i = 1; i < m; i++) {
			printf(" %d", memory[i]);
		}
		printf("\n");
	}

	//yydebug = 1;

	// open a file handle to a particular file:
	FILE *myfile = fopen(save, "r");
	// make sure it's valid:
	if (!myfile) {
		fprintf(stderr, "Couldn't load save file: %s\n", save);
		return 1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;

	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));

	fclose(myfile);

	Core* disabled = new Core(-1);

	Core* stack = new Core(-2);

	std::vector<Core*> renum(12, disabled);

	for (size_t i = 0; i < cores.size() && i < c; i++) {
		renum[compute[i]] = cores[i];
	}

	for (size_t i = 0; i < m; i++) {
		renum[memory[i]] = stack;
	}

	printf("\n");

	for (Core* c : renum) {
		printf("Core %d: length: %ld\n", c->corenum, c->instr.size());
		for (unsigned int i = 0; i < c->instr.size(); i++) {
			switch (c->instr[i]->type) {
			case NOP: printf("NOP\n"); break;
			case SWP: printf("SWP\n"); break;
			case SAV: printf("SAV\n"); break;
			case NEG: printf("NEG\n"); break;
			case ADD: printf("ADD "); printsrc(c->instr[i]->src); printf("\n"); break;
			case SUB: printf("SUB "); printsrc(c->instr[i]->src); printf("\n"); break;
			case JRO: printf("JRO "); printsrc(c->instr[i]->src); printf("\n"); break;
			case JMP: printf("JMP %d\n", c->instr[i]->label); break;
			case JEZ: printf("JEZ %d\n", c->instr[i]->label); break;
			case JNZ: printf("JNZ %d\n", c->instr[i]->label); break;
			case JGZ: printf("JGZ %d\n", c->instr[i]->label); break;
			case JLZ: printf("JLZ %d\n", c->instr[i]->label); break;
			case MOV: printf("MOV "); printsrc(c->instr[i]->src); printf(" "); printsrc(c->instr[i]->dest); printf("\n"); break;
			}
		}
	}

	FILE *lentxt = fopen("len.txt", "w");

	if (!lentxt) {
		fprintf(stderr, "Couldn't open output file: len.txt\n");
		return 1;
	}

	FILE *stacktxt = fopen("stack.txt", "w");

	if (!stacktxt) {
		fprintf(stderr, "Couldn't open output file: stack.txt\n");
		return 1;
	}

	FILE *progtxt = fopen("prog.txt", "w");

	if (!progtxt) {
		fprintf(stderr, "Couldn't open output file: prog.txt\n");
		return 1;
	}

	for (Core* c : renum) {
		fprintf(lentxt, "%lX\n", c->instr.size());
		fprintf(stacktxt, (c == stack) ? "1\n" : "0\n");
		size_t i = 0;
		while (i < c->instr.size()) {
			uint16_t r = (uint16_t) c->instr[i]->type;
			switch (r) {
			case MOV:
				r = r | (uint16_t) (c->instr[i]->dest - 1000) << 11;
			case ADD:
			case SUB:
			case JRO:
				r = r | ((uint16_t) c->instr[i]->src & (uint16_t) 0x7FF);
				break;
			case JMP:
			case JEZ:
			case JNZ:
			case JGZ:
			case JLZ:
				r = r | ((uint16_t) c->instr[i]->label & (uint16_t) 0xF);
				break;
			}
			fprintf(progtxt, "%04hX\n", r);
			i++;
		}
		while (i < 15) {
			fprintf(progtxt, "0000\n");
			i++;
		}
	}

	fclose(lentxt);
	fclose(stacktxt);
	fclose(progtxt);

    return 0;
}
