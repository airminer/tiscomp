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

struct Instr {
    int type;
    int src;
    int dest;
    int label;
};

extern "C" int yylex();
extern "C" int yyparse();

extern int corenum, instrn;

void yyerror(const char *s);

void pushLabel(char* lc);
void popLabels();
void pushJum(char* lc, Instr* i);
