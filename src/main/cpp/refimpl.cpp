#include "backend.hpp"

const char* getSrc(int i) {
	switch (i) {
	case NIL:  return "NIL";
	case ACC:  return "ACC";
	case ANY:  return "ANY";
	case LAST:  return "LAST";
	case UP:  return "UP";
	case RIGHT:  return "RIGHT";
	case DOWN:  return "DOWN";
	case LEFT:  return "LEFT";
	default:  return "%d";
	}
}

void refimpl_backend(const Puzzle &puzzle, const std::vector<Core*> &renum, const Core *stack) {
	FILE *program = fopen("refimpl.tis", "w");
	if (!program) {
		fprintf(stderr, "Couldn't open file: refimpl.tis");
		exit(1);
	}

	for (unsigned int n = 0; n < renum.size(); n++) {
		Core* c = renum[n];
		if (c == stack) {
			fprintf(stderr, "Warning: node %d is a stack node, which is not supported by the eviltrout tis-100 emulator.\n", n);
		}
		fprintf(program, "@%d\n", n);
		unsigned int i = 0;
		while (i < c->instr.size()) {
			fprintf(program, "%d:", i);
			switch (c->instr[i]->type) {
			case NOP: fprintf(program, "NOP\n"); break;
			case SWP: fprintf(program, "SWP\n"); break;
			case SAV: fprintf(program, "SAV\n"); break;
			case NEG: fprintf(program, "NEG\n"); break;
			case ADD: fprintf(program, "ADD "); fprintf(program, getSrc(c->instr[i]->src), c->instr[i]->src); fprintf(program, "\n"); break;
			case SUB: fprintf(program, "SUB "); fprintf(program, getSrc(c->instr[i]->src), c->instr[i]->src); fprintf(program, "\n"); break;
			case JRO: fprintf(program, "JRO "); fprintf(program, getSrc(c->instr[i]->src), c->instr[i]->src); fprintf(program, "\n"); break;
			case JMP: fprintf(program, "JMP %d\n", c->instr[i]->label); break;
			case JEZ: fprintf(program, "JEZ %d\n", c->instr[i]->label); break;
			case JNZ: fprintf(program, "JNZ %d\n", c->instr[i]->label); break;
			case JGZ: fprintf(program, "JGZ %d\n", c->instr[i]->label); break;
			case JLZ: fprintf(program, "JLZ %d\n", c->instr[i]->label); break;
			case MOV: fprintf(program, "MOV "); fprintf(program, getSrc(c->instr[i]->src), c->instr[i]->src); fprintf(program, " "); fprintf(program, getSrc(c->instr[i]->dest), c->instr[i]->dest); fprintf(program, "\n"); break;
			}
			i++;
		}
		if (i == 0)
			fprintf(program, "\n\n");
		else
			fprintf(program, "\n");
	}

	fclose(program);

	FILE *system = fopen("refimpl.sys", "w");
	if (!system) {
		fprintf(stderr, "Couldn't open file: refimpl.sys");
		exit(1);
	}

	for (int i = 0; i < 4; i++) {
		const std::vector<int> &data = puzzle.inStreams[i].data;
		if (data.size() > 0) {
			fprintf(system, "input-top\n%d\n", i);
			for (int d : data) {
				fprintf(system, "%d\n", d);
			}
			fprintf(system, "*\n\n");
		}
	}

	for (int i = 0; i < 4; i++) {
		if (puzzle.outStreams[i].data.size() > 0) {
			fprintf(system, "output-bottom\n%d\n\n", i + 8);
		}
	}

	fclose(system);

}