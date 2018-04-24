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
    corenum { startCore(); } lines ENDL { endCore(); };
corenum:
    '@' INT ENDL { if ($2 == corenum + 1) { printf("Core %d:\n", ++corenum); } else yyerror("Non-consecutive core number\n"); };
lines:
    lines line
  | line;
line:
    instr ENDL { popLabels(); instrn++; }
  | LABEL ':' ENDL { pushLabel($1); }
  | LABEL ':' instr ENDL { pushLabel($1); popLabels(); instrn++; }
  | ENDL;
instr:
    INSTR0 { pushInstr($1); }
  | INSTR1 src { pushInstr1($1, $2); }
  | INSTRL LABEL { pushInstrL($1, $2); }
  | INSTR2 src REG { pushInstr2($1, $2, $3); };
src:
    REG
  | INT;
%%
