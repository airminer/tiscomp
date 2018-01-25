#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>

enum Reg {
    NIL = 1000,
    ACC = 1001,
    ANY = 1002,
    LAST = 1003,
    UP = 1004,
    RIGHT = 1005,
    DOWN = 1006,
    LEFT = 1007
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
