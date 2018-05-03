#include <unordered_map>
#include <vector>
#include <algorithm>
#include <ctype.h>
#include <string.h>
#include <stdarg.h>
#include "save.hpp"
#include "save.tab.h"

int corenum = -1;

int instrn = 0;

std::unordered_map<std::string, int> labels;
std::vector<std::string> floating;
std::unordered_map<std::string, std::vector<Instr*>> unresolved;

std::vector<Core*> cores;
Core* core = NULL;

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

Instr::Instr(const int line, const int type, const int src, const int dest, const int label) : line(line),  type(type), src(src), dest(dest), label(label) {}
Core::Core(const int corenum) : corenum(corenum) {}

void pushLabel(char* lc) {
	std::string l(lc);
	if (labels.count(l) || std::find(floating.begin(), floating.end(), l) != floating.end()) {
		yyerror("Label %s is already defined", lc);
	} else {
		floating.push_back(l);
	}
}

void popLabels() {
    if(!floating.empty()) {
        for(std::string l : floating) {
            printf("%s --> %d\n", l.c_str(), instrn);
            labels[l] = instrn;
            if (unresolved.count(l)) {
				for (Instr* i : unresolved[l]) {
					i->label = instrn;
				}
                unresolved.erase(l);
            }
        }
        floating.clear();
    }
}

void clearLabels() {
	instrn = 0;
	popLabels();
	if (!unresolved.empty()) {
		for (std::pair<std::string, std::vector<Instr*>> e : unresolved) {
			for (Instr* i : e.second) {
				lineerror(i->line, "Label %s is undefined\n", e.first.c_str());
			}
		}
		exit(1);
	} else {
		labels.clear();
	}
}

Instr* pushInstr(const int type) {
	if (instrn > 14) {
		yyerror("Too many instructions\n");
	}
	Instr* i = new Instr(linenum, type, 0, 0, 0);
	core->instr.push_back(i);
	return i;
}

void pushInstr1(const int type, const int src) {
	Instr* i = pushInstr(type);
	i->src = src;
}

void pushInstrL(const int type, const char* lc) {
	Instr* i = pushInstr(type);
	std::string l(lc);
	if (labels.count(l)) {
		i->label = labels[l];
	} else {
		unresolved[l].push_back(i);
	}
}

void pushInstr2(const int type, const int src, const int dest) {
	Instr* i = pushInstr(type);
	i->src = src;
	i->dest = dest;
}

void startCore() {
		core = new Core(corenum);
}

void endCore() {
	clearLabels();
	cores.push_back(core);
}
