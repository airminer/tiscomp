#include <stdio.h>
#include <stdlib.h>

extern "C" int yyparse();
extern "C" FILE *yyin;
extern int linenum;

int main(int argc, char* argv[]) {
    // open a file handle to a particular file:
	FILE *myfile = fopen("save.txt", "r");
	// make sure it's valid:
	if (!myfile) {
		printf("I can't open save.txt!");
		return 1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;

	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));

}

void yyerror(const char *s) {
	printf("Parse error at line %d: %s",linenum, s);
	// might as well halt now:
	exit(-1);
}