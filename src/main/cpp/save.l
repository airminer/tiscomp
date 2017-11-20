%option noyywrap
%option caseless
%{
    #define YY_DECL extern "C" int yylex()
    #include "save.tab.h"
    int linenum = 1;
    int eofpad = 1;
%}
%%

[, \t]         ;
#.*             ;
MOV             { yylval.sval = (char*) "MOV"; return MOV; }
NOP             { yylval.sval = (char*) "NOP"; return INSTR0; }
SWP             { yylval.sval = (char*) "SWP"; return INSTR0; }
SAV             { yylval.sval = (char*) "SAV"; return INSTR0; }
NEG             { yylval.sval = (char*) "NEG"; return INSTR0; }
ADD             { yylval.sval = (char*) "ADD"; return INSTR1; }
SUB             { yylval.sval = (char*) "SUB"; return INSTR1; }
JRO             { yylval.sval = (char*) "JRO"; return INSTR1; }
JMP             { yylval.sval = (char*) "JMP"; return INSTRL; }
JEZ             { yylval.sval = (char*) "JEZ"; return INSTRL; }
JNZ             { yylval.sval = (char*) "JNZ"; return INSTRL; }
JGZ             { yylval.sval = (char*) "JGZ"; return INSTRL; }
JLZ             { yylval.sval = (char*) "JLZ"; return INSTRL; }
ACC             { yylval.sval = (char*) "ACC"; return REG; }
NIL             { yylval.sval = (char*) "NIL"; return REG; }
LEFT            { yylval.sval = (char*) "LEFT"; return REG; }
RIGHT           { yylval.sval = (char*) "RIGHT"; return REG; }
UP              { yylval.sval = (char*) "UP"; return REG; }
DOWN            { yylval.sval = (char*) "DOWN"; return REG; }
ANY             { yylval.sval = (char*) "ANY"; return REG; }
LAST            { yylval.sval = (char*) "LAST"; return REG; }
[0-9]+          { yylval.ival = atoi(yytext); return INT;}
[a-zA-Z0-9]+    { yylval.sval = strdup(yytext); return LABEL;}
\n              { linenum++; return ENDL; }
.               { return yytext[0]; }
<<EOF>>         { if(eofpad) { eofpad = 0; return ENDL; } else yyterminate(); };
%%