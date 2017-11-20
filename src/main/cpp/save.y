%{
    #include <stdio.h>
    #include <stdlib.h>

    extern "C" int yylex();
    extern "C" int yyparse();

    void yyerror(const char *s);

    int corenum = -1;

%}

%union {
    int ival;
    char* sval;
}

%token <ival> INT
%token ENDL
%token <sval> LABEL
%token <sval> MOV
%token <sval> INSTR0
%token <sval> INSTR1
%token <sval> INSTRL
%token <sval> REG

%type <sval> src

%%
cores:
    cores core
  | core;
core:
    corenum lines ENDL
corenum:
    '@' INT ENDL { if ($2 == corenum + 1) printf("Core %d:\n", corenum++); else yyerror("Non-consecutive core number");};
lines:
    lines line
  | line;
line:
    instr ENDL
  | LABEL ':' ENDL
  | LABEL ':' instr ENDL
  | ENDL;
instr:
    INSTR0
  | INSTR1 src
  | INSTRL LABEL
  | MOV src REG { printf("%s --> %s\n", $2, $3); };
src:
    REG
  | INT { char* str = (char*) malloc(5); $$ = itoa($1, str, 10); };
%%