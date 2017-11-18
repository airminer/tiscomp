%option noyywrap
%option caseless
%{
    #define YY_DECL extern "C" int yylex()
    #include "save.tab.h"
    int linenum = 1;
%}
%%

#.*             ;
MOV             { return MOV; }
NOP             { return NOP; }
SWP             { return SWP; }
SAV             { return SAV; }
NEG             { return NEG; }
ADD             { return ADD; }
SUB             { return SUB; }
JRO             { return JRO; }
JMP             { return JMP; }
JEZ             { return JEZ; }
JNZ             { return JNZ; }
JGZ             { return JGZ; }
JLZ             { return JLZ; }
ACC             { return ACC; }
NIL             { return NIL; }
LEFT            { return LEFT; }
RIGHT           { return RIGHT; }
UP              { return UP; }
DOWN            { return DOWN; }
ANY             { return ANY; }
LAST            { return LAST; }
[0-9]+          { yylval.ival = atoi(yytext); return INT;}
[a-zA-Z0-9]+    { yylval.sval = strdup(yytext); return LABEL;}
\n              { linenum++; return ENDL; }
.               { return yytext[0]; };

%%