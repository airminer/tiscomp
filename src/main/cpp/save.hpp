#include <stdio.h>
#include <stdlib.h>
#include <string>

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
    Instr(int, int, int, int, int);
};

extern "C" int yylex();
extern "C" int yyparse();

extern int corenum, instrn, linenum;

void yyerror(const char*, ...);
void lineerror(int, const char*, ...);

void pushLabel(char*);
void popLabels();
void clearLabels();
void pushJump(char*, int);
