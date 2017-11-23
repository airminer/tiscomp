#include <cstdio>
#include <cstdlib>
#include <cstdarg>

extern "C" int yyparse();
extern "C" FILE *yyin;
extern int linenum, yydebug;

void lineerror(int line, const char *s, ...) {
	fprintf(stderr, "Parse error at line %d: ", line);

	va_list argptr;
	va_start(argptr, s);
	vfprintf(stderr, s, argptr);
	va_end(argptr);
}

void yyerror(const char *s, ...) {
	fprintf(stderr, "Parse error at line %d: ", linenum);

	va_list argptr;
	va_start(argptr, s);
	vfprintf(stderr, s, argptr);
	va_end(argptr);

	// might as well halt now:
	exit(1);
}

int main(int argc, char* argv[]) {

    //yydebug = 1;

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
