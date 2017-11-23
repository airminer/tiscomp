#include <unordered_map>
#include <vector>
#include <algorithm>
#include "save.hpp"

int corenum = -1;

int instrn = 0;

std::unordered_map<std::string, int> labels;
std::vector<std::string> floating;
std::unordered_map<std::string, Instr*> unresolved;

void pushLabel(char* lc) {
	std::string l(lc);
	if (labels.count(l) || std::find(floating.begin(), floating.end(), l) != floating.end()) {
		yyerror("Label %s is already defined");
	} else {
		floating.push_back(l);
	}
}

void popLabels() {
    for(std::string l : floating) {
		labels[l] = instrn;
		if (unresolved.count(l)) {
			unresolved[l]->label = instrn;
			unresolved.erase(l);
		}
    }
}

void pushJump(char* lc, Instr* i) {
	std::string l(lc);
	if (labels.count(l)) {
		i->label = labels[l];
	} else {
		unresolved[l] = i;
	}
}
