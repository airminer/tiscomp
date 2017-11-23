%option noyywrap
%option caseless
%{
    #include <ctype.h>
    #define YY_DECL extern "C" int yylex()
    #include "save.hpp"
    #include "save.tab.h"

    int linenum = 1;
    int eofpad = 1;
%}

%x LSTATE

%%

[, \t\r]                ;
<LSTATE>[, \t]           ;
#.*                     ;
<LSTATE>#.*              ;
["$-+\--9;-~]+/:        { yylval.sval = strupr(strdup(yytext)); return LABEL;}
<LSTATE>["$-+\--9;-~]+   { yylval.sval = strupr(strdup(yytext)); BEGIN(INITIAL); return LABEL; }
NOP                     { yylval.ival = NOP; return INSTR0; }
SWP                     { yylval.ival = SWP; return INSTR0; }
SAV                     { yylval.ival = SAV; return INSTR0; }
NEG                     { yylval.ival = NEG; return INSTR0; }
ADD                     { yylval.ival = ADD; return INSTR1; }
SUB                     { yylval.ival = SUB; return INSTR1; }
JRO                     { yylval.ival = JRO; return INSTR1; }
JMP                     { yylval.ival = JMP; BEGIN(LSTATE); return INSTRL; }
JEZ                     { yylval.ival = JEZ; BEGIN(LSTATE); return INSTRL; }
JNZ                     { yylval.ival = JNZ; BEGIN(LSTATE); return INSTRL; }
JGZ                     { yylval.ival = JGZ; BEGIN(LSTATE); return INSTRL; }
JLZ                     { yylval.ival = JLZ; BEGIN(LSTATE); return INSTRL; }
MOV                     { yylval.ival = MOV; return INSTR2; }
ACC                     { yylval.ival = ACC; return REG; }
NIL                     { yylval.ival = NIL; return REG; }
LEFT                    { yylval.ival = LEFT; return REG; }
RIGHT                   { yylval.ival = RIGHT; return REG; }
UP                      { yylval.ival = UP; return REG; }
DOWN                    { yylval.ival = DOWN; return REG; }
ANY                     { yylval.ival = ANY; return REG; }
LAST                    { yylval.ival = LAST; return REG; }
[0-9]+                  { yylval.ival = atoi(yytext); return INT;}
\n                      { linenum++; return ENDL; }
<LSTATE>\n              { linenum++; BEGIN(INITIAL); return ENDL; }
[@:]                    { return yytext[0]; }
.                       { yyerror("Unexpected token: %s", yytext); }
<LSTATE>.               { yyerror("Unexpected token: %s", yytext); }
<<EOF>>                 { if(eofpad) { eofpad = 0; return ENDL; } else yyterminate(); };
%%
