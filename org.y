%{
#include <cstdio>
#include <iostream>
using namespace std;
#define YYDEBUG 1 // debugger
// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);
%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
	int ival;
	char *sval;
}

// constant-string token
%token ENDLN
%token EOF_TOKEN

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <sval> SECTION
%token <sval> TITLE
%token <sval> WHITESPACE
%token <sval> DIRECTIVE // eg #+DRAWERS: TESTDRAWER
%token <sval> PRIORITY
%token <ival> STARS //   number of stars starting the line
%token <sval> TAG
%token <sval> WORD
%token <sval> MARKER
%token <ival> DEDENT
%token <ival> INDENT
%token <sval> TODO
%token <sval> DRAWERSTART
%token <sval> DRAWERKEY
%token <sval> DRAWERVALUE
%token <sval> DRAWEREND
%token <sval> BLOCK /* The block of text following a list item. Where each line must
have an indention to match the first character of the first */
%%

doc:            SECTION doc2
        |       headline doc
        |       /* empty */
        ;

doc2:           headline doc
        |       /* empty */
        ;

headline:        STARS todo_keyword priority title tags

        ;

todo_keyword:   TODO WHITESPACE
        |       TODO
        |       /* empty */
        ;

priority:       PRIORITY WHITESPACE
        |       PRIORITY
        |       /* empty */
        ;

title:          title WORD
        |       title WHITESPACE
        |       WORD
        ;

/*title:         TITLE /* a headline is treated differently if the first word of the
               title is a org-comment-string
               if the title is org-footnote-section it will be considered a footnote
               section. I don't know how I'm going to handle this yet. Is this part
               of the parsing, or the lexing? */
  //      |      /* empty */
    //    ;

tags:           tags TAG WHITESPACE
        |       tags TAG
        |      /* empty */
        ;


/* the follwing or for a future version
greater_element

element

object
*/

%%

main( int argc, const char* argv[] )
{
	// Prints each argument on the command line.
  	/*for( int i = 0; i < argc; i++ )
    {
		printf( "arg %d: %s\n", i, argv[i] );
        }*/

    FILE *myfile;
    if (argc > 1) {
      // we have a file name
      myfile = fopen(argv[1], "r");
    }
    else {
      myfile = fopen("test.org", "r");
    }
    //yydebug = 1;
	// open a file handle to a particular file:

	// make sure it is valid:
	if (!myfile) {
		cout << "I can't open test.org!" << endl;
		return -1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;

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
