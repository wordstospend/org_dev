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
%token EOF

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
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
doc:            directives body
        ;


directives:     directives DIRECTIVE ENDLN
        |       directives DIRECTIVE WHITESPACE ENDLN
        |       directives WHITESPACE ENDLN
        |       directives ENDLN
        |       /* empty */
        ;

body:           body headline_block
        |       headline_block
        ;

headline_block: headline ENDLN headline_body
        |       headline EOF
        ;

headline:       STARS todo_state headline_with_priority tags
        ;

todo_state:     TODO
        |
        ;

headline_with_priority: PRIORITY headline_text
        |       headline_text PRIORITY headline_text
        |       headline_text PRIORITY
        |       headline_text
        |       PRIORITY
        |       ;

headline_text:  headline_text WORD
        |       headline_text WHITESPACE
        |       WORD
        |       WHITESPACE
                ;

tags:           tags TAG
        |
        ;


headline_body:  headline_body ENDLN
        |       headline_body EOF
        |       entry
        |       text
        |       DEDENT
        |       ENDLN
        ;
text:           text WORD
        |       text WHITESPACE
        |       WORD
        |       WHITESPACE
        ;

entry:          MARKER BLOCK
        |       MARKER /* empty */
        |       MARKER BLOCK INDENT entry
;

%%

main() {
    //yydebug = 1;
	// open a file handle to a particular file:
	FILE *myfile = fopen("test.org", "r");
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
	cout << "EEK, parse error!  Message: " << s << endl;
	// might as well halt now:
	exit(-1);
}
