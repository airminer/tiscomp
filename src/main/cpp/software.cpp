#include "backend.hpp"

const char* getSrcStr(const int i) {
	switch (i) {
	case NIL: return "0";
	case ACC: return "acc";
	case ANY: return "any";
	case LAST: return "last";
	case LEFT: return "left";
	case RIGHT: return "right";
	case UP: return "up";
	case DOWN: return "down";
	default: return "%d";
	}
}

const char* getInstrStr(const int i) {
	switch (i) {
	case NOP: return "";
	case SWP: return "swp();";
	case SAV: return "bak = acc;";
	case NEG: return "acc = -acc;";
	case ADD: return "add(i);";
	case SUB: return "sub(i);";
	case JRO: return "jro(i);";
	case JMP: return "pc = %d;";
	case JEZ: return "if(acc == 0) pc = %d; else";
	case JNZ: return "if(acc != 0) pc = %d; else";
	case JGZ: return "if(acc > 0) pc = %d; else";
	case JLZ: return "if(acc < 0) pc = %d; else";
	case MOV: return "mov(i, %s);";
	default: return "";
	}
}

void software_backend(const Puzzle &puzzle, const std::vector<Core*> &renum, const Core *stack) {
	FILE *output = fopen("src/main/cpp/tisprog.cpp", "w");
	if (!output) {
		fprintf(stderr, "Couldn't open file: src/main/cpp/tisprog.cpp");
		exit(1);
	}

	fprintf(output,
		"#include \"tisvm.hpp\"\n"
	);

	for (int i = 0; i < 12; i++) {
		if (renum[i]->instr.size() > 0) {
			int instrn = renum[i]->instr.size();
			fprintf(output,
				"class Proc%d : public Proc {\n"
				"public:\n"
				"    Proc%d() : Proc(%d) {}\n"
				"    void step() override {\n"
				"        switch(pc) {\n", i, i, instrn
			);
			for (int j = 0; j < instrn; j++) {
				Instr* instr = renum[i]->instr[j];
				fprintf(output, "        case %d: ", j);
				switch (instr->type) {
				case MOV:
					if (instr->dest == NIL) {
						fprintf(output, "{int i; if(readFrom(i, %s))  pc = %d; }", getSrcStr(instr->src), (j + 1) % instrn);
						break;
					} else if (instr->dest == ACC) {
						fprintf(output, "if(readFrom(acc, %s))  pc = %d;", getSrcStr(instr->src), (j + 1) % instrn);
						break;
					} else
						fprintf(output, "if(!write && !writec) ");
				case ADD: case SUB: case JRO:
					fprintf(output, "{ int i");
					switch (instr->src) {
					case ANY: case LAST:
					case LEFT: case RIGHT: case UP: case DOWN:
						fprintf(output, "; if(readFrom(i, %s)) {", getSrcStr(instr->src));
						break;
					default:
						fprintf(output, " = ");
						fprintf(output, getSrcStr(instr->src), instr->src);
						fprintf(output, "; {");
						break;
					}
					fprintf(output, getInstrStr(instr->type), getSrcStr(instr->dest));
					if(instr->type != MOV)
						fprintf(output, " pc = %d;", (j + 1) % instrn);
					fprintf(output, " }}");
					break;
				case NOP: case SWP:	case SAV: case NEG:
				case JEZ: case JNZ:	case JGZ: case JLZ:
					fprintf(output, getInstrStr(instr->type), instr->label);
					fprintf(output, " pc = %d;", (j + 1) % instrn);
					break;
				case JMP:
					fprintf(output, getInstrStr(instr->type), instr->label);
					break;
				default:
					fprintf(stderr, "ERROR");
					exit(1);
				}
				fprintf(output, " break;\n");
			}

			fprintf(output,
				"        }\n"
				"    }\n"
				"};\n"
			);
		}
	}

	fprintf(output,
		"int main(int argc, char* argv[]) {\n"
		"    init_array();\n"
	);
	for (int i = 0; i < 12; i++) {
		if (renum[i] == stack) {
			fprintf(output, "    insert_node(%d, new Stack());\n", i);
		} else if (renum[i]->instr.size() > 0) {
			fprintf(output, "    insert_node(%d, new Proc%d());\n", i, i);
		}
	}
	for (int i = 0; i < 4; i++) {
		if (puzzle.inStreams[i].data.size() > 0) {
			char s[8];
			sprintf(s, "in%d.txt", i);
			FILE *instr = fopen(s, "w");
			for (int n : puzzle.inStreams[i].data) {
				fprintf(instr, "%d\n", n);
			}
			fclose(instr);
			fprintf(output, "    insert_inStream(%d, new InStream(fopen(\"%s\", \"r\")));\n", i, s);
		}
	}
	for (int i = 0; i < 4; i++) {
		if (puzzle.outStreams[i].data.size() > 0) {
			char s[9];
			sprintf(s, "out%d.txt", i);
			FILE *outstr = fopen(s, "w");
			for (int n : puzzle.outStreams[i].data) {
				fprintf(outstr, "%d\n", n);
			}
			fclose(outstr);
			fprintf(output, "    insert_outStream(%d, new OutStream(fopen(\"%s\", \"r\")));\n", i, s);
		}
	}
	fprintf(output,
		"    run();\n"
		"    return 0;\n"
		"}\n"
	);
	fclose(output);

}
