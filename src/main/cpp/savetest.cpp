#include <cstdio>
#include <cstdlib>
#include <cstdarg>

extern "C" int yyparse();
extern "C" FILE *yyin;
extern int linenum;

void yyerror(const char *s) {
	printf(s);
}

int main(int argc, char* argv[]) {
    // open a file handle to a particular file:
    fprintf(stderr, "TEST");
    yyerror("TEST1");
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