#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "puzzle.hpp"
#include "save.hpp"

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

	FILE *streamstxt = fopen("streams.txt", "w");

	if (!streamstxt) {
		fprintf(stderr, "Couldn't open output file: streams.txt\n");
		return 1;
	}

	FILE *slentxt = fopen("slen.txt", "w");

	if (!slentxt) {
		fprintf(stderr, "Couldn't open output file: slen.txt\n");
		return 1;
	}

	for (Stream s : puzzle.inStreams) {
		fprintf(slentxt, "%02lX\n", s.data.size());
		size_t i = 0;
		while (i < s.data.size()) {
			fprintf(streamstxt, "%03X\n", s.data[i] & 0x7FF);
			i++;
		}
		while (i < 39) {
			fprintf(streamstxt, "000\n");
			i++;
		}
	}
	for (Stream s : puzzle.outStreams) {
		fprintf(slentxt, "%02lX\n", s.data.size());
		size_t i = 0;
		while (i < s.data.size()) {
			fprintf(streamstxt, "%03X\n", s.data[i] & 0x7FF);
			i++;
		}
		while (i < 39) {
			fprintf(streamstxt, "000\n");
			i++;
		}
	}

	fclose(streamstxt);
	fclose(slentxt);

    return 0;
}
