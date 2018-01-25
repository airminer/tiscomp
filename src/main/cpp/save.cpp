#include <unordered_map>
#include <vector>
#include <algorithm>
#include <cctype>
#include <cstring>
#include "save.hpp"
#include "save.tab.h"

int corenum = -1;

int instrn = 0;

std::unordered_map<std::string, int> labels;
std::vector<std::string> floating;
std::unordered_map<std::string, std::vector<Instr*>> unresolved;

std::vector<Instr*> core;

Instr::Instr(int line, int type, int src, int dest, int label) : line(line),  type(type), src(src), dest(dest), label(label) {}

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
	printf("COREDUMP\n");
	for (Instr* i : core) {
		printf("%d:JMP %d\n", i->line, i->label);
	}
	if (!unresolved.empty()) {
		std::string l = "";
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

void pushJump(char* lc, int type) {
    printf("JMPLINE: %d\n", linenum);
	Instr* i = new Instr(linenum, type, 0, 0, 0);
	core.push_back(i);
	std::string l(lc);
	if (labels.count(l)) {
		i->label = labels[l];
	} else {
		unresolved[l].push_back(i);
	}
}
