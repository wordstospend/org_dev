%{
#include <cstdio>
#include <iostream>
#include "org.h" // to get the node struct typedefs
using namespace std;
#define YYDEBUG 1 // debugger
// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;


void yyerror(const char *s);
FILE * astFile;
void output_ast(FILE * outputFile, documentNode * node);

%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
	int ival;
	char *sval;
};

// constant-string token
%token ENDLN
%token EOF_TOKEN


// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <sval> BLANK_LINES
%token <ival> HEADLINE_BEGIN
%token <sval> WORD
%token <sval> WHITESPACE

%%


snazzle:
                snazle HEADLINE_BEGEIN { printf("headline %i", $1); }
        |       snazzle WORD { printf("word %s", $1); }
        |       snazzle BLANKLINES { printf("blanklines '%s'", $1); }
        |       snazzle WHITESPACE { printf("whitespace '%s'", $1); }
        |       HEADLINE_BEGEIN { printf("headline %i", $1); }
        |       WORD { printf("word %s", $1); }
        |       BLANKLINES { printf("blanklines '%s'", $1); }
        |       WHITESPACE { printf("whitespace '%s'", $1); }
        ;


%%

main( int argc, const char* argv[] )
{
	// Prints each argument on the command line.
  	for( int i = 0; i < argc; i++ )
    {
		printf( "arg %d: %s\n", i, argv[i] );
        }

    FILE *sourceFile = NULL;
    //    FILE *astFile = NULL;
    switch (argc)
      {
      case 1:
        sourceFile = fopen("test.org", "r");
        cout << "opening default test file" << endl;
        break;

      case 3:
        astFile = fopen(argv[2], "w");
        cout << "opening passed ast file" << endl;
        if (!astFile) {
          cout << "cannot open \"" << argv[2] << "\"" << endl;
          return -1;
        }
      case 2:
        sourceFile = fopen(argv[1], "r");
        cout << "opening passed source file" << endl;
        break;
      }

    // make sure it is valid:
	if (!sourceFile) {
		cout << "I can't open source file" << endl;
		return -1;
	}

    //        yydebug = 1;

	// set flex to read from it instead of defaulting to STDIN:
	yyin = sourceFile;


	// parse through the input until there is no more:
	do {
        cout << "first call" << endl;
		yyparse();
        cout << "after " << endl;
	} while (!feof(yyin));

}

void yyerror(const char *s) {
	cout << "Parse error!  Message: " << s << endl;
	// might as well halt now:
	exit(-1);
}
