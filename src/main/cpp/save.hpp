#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>

enum Reg {
    ACC = 1000,
    NIL = 1001,
    LEFT = 1002,
    RIGHT = 1003,
    UP = 1004,
    DOWN = 1005,
    ANY = 1006,
    LAST = 1007
};

enum InstrType {
	NOP, SWP, SAV, NEG, ADD, SUB, JRO, JMP, JEZ, JNZ, JGZ, JLZ, MOV
};

struct Instr {
    int line;
    int type;
    int src;
    int dest;
    int label;
    Instr(const int, const int, const int, const int, const int);
};

struct Core {
	int corenum;
	std::vector<Instr*> instr;
	Core(const int);
};

extern "C" int yylex();
extern "C" int yyparse();

extern int corenum, instrn, linenum;

void yyerror(const char*, ...);
void lineerror(int, const char*, ...);

void pushLabel(char*);
void popLabels();

Instr* pushInstr(const int);
void pushInstr1(const int, const int);
void pushInstrL(const int, const char*);
void pushInstr2(const int, const int, const int);

void startCore();
void endCore();
