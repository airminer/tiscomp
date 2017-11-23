%option noyywrap
%option caseless
%{
    #include <ctype.h>
    #define YY_DECL extern "C" int yylex()
    #include "save.tab.h"

    int linenum = 1;
    int eofpad = 1;

    char* strtoupper(char* s) {
        char* ret = strdup(s);
        while ((*ret = toupper(*ret))) ret++;
        return ret;
    }
%}

%x LABEL

%%

[, \t]                  ;
<LABEL>[, \t]           ;
#.*                     ;
<LABEL>#.*              ;
["$-+\--9;-~]+/:        { yylval.sval = strtoupper(yytext); return LABEL;}
<LABEL>["$-+\--9;-~]+   { yylval.sval = strtoupper(yytext); BEGIN(INITIAL); return LABEL; }
NOP                     { yylval.sval = (char*) "NOP"; return INSTR0; }
SWP                     { yylval.sval = (char*) "SWP"; return INSTR0; }
SAV                     { yylval.sval = (char*) "SAV"; return INSTR0; }
NEG                     { yylval.sval = (char*) "NEG"; return INSTR0; }
ADD                     { yylval.sval = (char*) "ADD"; return INSTR1; }
SUB                     { yylval.sval = (char*) "SUB"; return INSTR1; }
JRO                     { yylval.sval = (char*) "JRO"; return INSTR1; }
JMP                     { yylval.sval = (char*) "JMP"; BEGIN(LABEL); return INSTRL; }
JEZ                     { yylval.sval = (char*) "JEZ"; BEGIN(LABEL); return INSTRL; }
JNZ                     { yylval.sval = (char*) "JNZ"; BEGIN(LABEL); return INSTRL; }
JGZ                     { yylval.sval = (char*) "JGZ"; BEGIN(LABEL); return INSTRL; }
JLZ                     { yylval.sval = (char*) "JLZ"; BEGIN(LABEL); return INSTRL; }
MOV                     { yylval.sval = (char*) "MOV"; return INSTR2; }
ACC                     { yylval.sval = (char*) "ACC"; return REG; }
NIL                     { yylval.sval = (char*) "NIL"; return REG; }
LEFT                    { yylval.sval = (char*) "LEFT"; return REG; }
RIGHT                   { yylval.sval = (char*) "RIGHT"; return REG; }
UP                      { yylval.sval = (char*) "UP"; return REG; }
DOWN                    { yylval.sval = (char*) "DOWN"; return REG; }
ANY                     { yylval.sval = (char*) "ANY"; return REG; }
LAST                    { yylval.sval = (char*) "LAST"; return REG; }
[0-9]+                  { yylval.ival = atoi(yytext); return INT;}
\n                      { linenum++; return ENDL; }
<LABEL>\n               { linenum++; BEGIN(INITIAL); return ENDL; }
.                       { return yytext[0]; }
<LABEL>.                { BEGIN(INITIAL); return yytext[0]; }
<<EOF>>                 { if(eofpad) { eofpad = 0; return ENDL; } else yyterminate(); };
%%
