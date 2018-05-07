#include <stdio.h>
#include <stdlib.h>
#include "puzzle.hpp"
#include "save.hpp"
#include "backend.hpp"

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

	Puzzle puzzle = puzzle_parser(file);

	if (puzzle.compute.size() > 0) {
		printf("Compute tiles:\n0:%d", puzzle.compute[0]);
		for (size_t i = 1; i < puzzle.compute.size(); i++) {
			printf(" %ld:%d", i, puzzle.compute[i]);
		}
		printf("\n");
	}

	if (puzzle.memory.size() > 0) {
		printf("Memory tiles:\n%d", puzzle.memory[0]);
		for (size_t i = 1; i < puzzle.memory.size(); i++) {
			printf(" %d", puzzle.memory[i]);
		}
		printf("\n");
	}

	//yydebug = 1;

	// open a file handle to a particular file:
	FILE *myfile = fopen(save, "r");
	// make sure it's valid:
	if (!myfile) {
		fprintf(stderr, "Couldn't load save file: %s\n", save);
		exit(1);
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

	for (size_t i = 0; i < cores.size() && i < puzzle.compute.size(); i++) {
		renum[puzzle.compute[i]] = cores[i];
	}

	for (int i : puzzle.memory) {
		renum[i] = stack;
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

	printf("\n");

	fpga_backend(puzzle, renum, stack);
	software_backend(puzzle, renum, stack);
	refimpl_backend(puzzle, renum, stack);

    return 0;
}
