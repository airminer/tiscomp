%{
   #define YYERROR_VERBOSE
   #define YYDEBUG 1
   #include "save.hpp"
   #include <stdio.h>
   #include <cstdlib>
%}

%union {
    int ival;
    char* sval;
}

%token <ival> INT
%token ENDL
%token <sval> LABEL
%token <ival> INSTR0
%token <ival> INSTR1
%token <ival> INSTRL
%token <ival> INSTR2
%token <ival> REG

%type <ival> src

%%
cores:
    cores core
  | core;
core:
    corenum lines ENDL { clearLabels(); };
corenum:
    '@' INT ENDL { if ($2 == corenum + 1) { printf("Core %d:\n", ++corenum); } else yyerror("Non-consecutive core number\n"); };
lines:
    lines line
  | line;
line:
    instr ENDL { instrn++; popLabels(); }
  | LABEL ':' ENDL { pushLabel($1); }
  | LABEL ':' instr ENDL { pushLabel($1); instrn++; popLabels(); }
  | ENDL;
instr:
    INSTR0
  | INSTR1 src
  | INSTRL LABEL { pushJump($2, $1); }
  | INSTR2 src REG;
src:
    REG
  | INT;
%%
