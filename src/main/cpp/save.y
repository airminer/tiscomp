%{
    #include <cstdio>

    extern "C" int yylex();
    extern "C" int yyparse();
    //extern "C" FILE *yyin;

    void yyerror(const char *s);

    int corenum = 0;
%}

%union {
    int ival;
    char* sval;
}

%token <ival> INT
%token ENDL
%token <sval> LABEL
%token MOV
%token NOP
%token SWP
%token SAV
%token NEG
%token ADD
%token SUB
%token JRO
%token JMP
%token JEZ
%token JNZ
%token JGZ
%token JLZ
%token ACC
%token NIL
%token LEFT
%token RIGHT
%token UP
%token DOWN
%token ANY
%token LAST
%%
cores:
    cores core
  | core;
core:
    corenum lines ENDL
corenum:
    '@' INT ENDL { if ($2 == corenum + 1) corenum++; else yyerror("Non-consecutive core number");};
lines:
    lines line
  | line;
line:
    instr ENDL
  | LABEL ':' ENDL
  | LABEL ':' instr ENDL
  | ENDL;
instr:
    instr0
  | instr1 src
  | instrL LABEL
  | MOV src reg;
instr0:
    NOP | SWP | SAV | NEG;
instr1:
    ADD | SUB | JRO;
instrL:
    JMP | JEZ | JNZ | JGZ | JLZ;
reg:
    ACC | NIL | LEFT | RIGHT | UP | DOWN | ANY | LAST;
src:
    reg
  | INT;
%%
void yyerror(const char *s) {
	printf("Parse error: %s",s);
	// might as well halt now:
	exit(-1);
}