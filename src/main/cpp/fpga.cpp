#include <stdio.h>
#include <stdlib.h>
#include "backend.hpp"
#include "puzzle.hpp"
#include "save.hpp"

void fpga_backend(const Puzzle &puzzle, const std::vector<Core*> &renum, const Core *stack) {
	FILE *lentxt = fopen("len.txt", "w");

	if (!lentxt) {
		fprintf(stderr, "Couldn't open output file: len.txt\n");
		exit(1);
	}

	FILE *stacktxt = fopen("stack.txt", "w");

	if (!stacktxt) {
		fprintf(stderr, "Couldn't open output file: stack.txt\n");
		exit(1);
	}

	FILE *progtxt = fopen("prog.txt", "w");

	if (!progtxt) {
		fprintf(stderr, "Couldn't open output file: prog.txt\n");
		exit(1);
	}

	for (Core* c : renum) {
		fprintf(lentxt, "%zX\n", c->instr.size());
		fprintf(stacktxt, (c == stack) ? "1\n" : "0\n");
		size_t i = 0;
		while (i < c->instr.size()) {
			uint16_t r = (uint16_t)c->instr[i]->type;
			switch (r) {
			case MOV:
				r = r | (uint16_t)(c->instr[i]->dest - 1000) << 11;
			case ADD:
			case SUB:
			case JRO:
				r = r | ((uint16_t)c->instr[i]->src & (uint16_t)0x7FF);
				break;
			case JMP:
			case JEZ:
			case JNZ:
			case JGZ:
			case JLZ:
				r = r | ((uint16_t)c->instr[i]->label & (uint16_t)0xF);
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
		exit(1);
	}

	FILE *slentxt = fopen("slen.txt", "w");

	if (!slentxt) {
		fprintf(stderr, "Couldn't open output file: slen.txt\n");
		exit(1);
	}

	for (Stream s : puzzle.inStreams) {
		fprintf(slentxt, "%02zX\n", s.data.size());
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
		fprintf(slentxt, "%02zX\n", s.data.size());
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
}
