%{
   #include "save.hpp"
%}

%union {
    int ival;
    char* sval;
}

%token <ival> INT
%token ENDL
%token <sval> LABEL
%token <sval> INSTR0
%token <sval> INSTR1
%token <sval> INSTRL
%token <sval> INSTR2
%token <sval> REG

%type <sval> src

%%
cores:
    cores core
  | core;
core:
    corenum lines ENDL
corenum:
    '@' INT ENDL { yyerror("TEST"); if ($2 == corenum + 1) printf("Core %d:\n", corenum++); else yyerror("Non-consecutive core number");};
lines:
    lines line
  | line;
line:
    instr ENDL { instrn++; popLabels(); };
  | LABEL ':' ENDL { pushLabel($1); };
  | LABEL ':' instr ENDL { pushLabel($1); instrn++; popLabels(); };
  | ENDL;
instr:
    INSTR0
  | INSTR1 src
  | INSTRL LABEL
  | INSTR2 src REG { printf("%s --> %s\n", $2, $3); };
src:
    REG
  | INT { char* str = (char*) malloc(5); $$ = itoa($1, str, 10); };
%%
