#ifndef SAVE_HPP
#define SAVE_HPP

#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>

enum Reg {
    NIL = 1000,
    ACC = 1001,
    ANY = 1002,
    LAST = 1003,
    LEFT = 1004,
    RIGHT = 1005,
    UP = 1006,
    DOWN = 1007
};

enum InstrType {
	MOV = 0x0000,
	ADD = 0x6000,
	SUB = 0x6800,
	JRO = 0x7000,
	JMP = 0x7FA0,
	JEZ = 0x7FB0,
	JNZ = 0x7FC0,
	JGZ = 0x7FD0,
	JLZ = 0x7FE0,
	SWP = 0x7FFC,
	SAV = 0x7FFD,
	NEG = 0x7FFE,
	NOP = 0x7FFF
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

extern int yydebug, corenum, instrn, linenum;

extern FILE *yyin;

extern std::vector<Core*> cores;

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

#endif // !SAVE_HPP
