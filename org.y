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

%%
doc:            directives body
        |       body
        ;
whiteline:      WHITESPACE ENDLN
        |       ENDLN
        ;

directives:     directives DIRECTIVE ENDLN
        |       directives whiteline
        |       DIRECTIVE ENDLN
        ;

body:           body headline_block
        |       body whiteline
        |       headline_block
        ;

headline_block: headline ENDLN headline_body
        |       headline ENDLN
        |       headline
        ;

headline:       STARS todo_state headline_with_priority tags
        ;

todo_state:     TODO
        |       ;

priority:       PRIORITY
        |       ;

headline_with_priority: headline_text priority headline_text
                ;

headline_text:  headline_text WORD
        |       headline_text WHITESPACE
        |       ;

tags:           tags TAG
        |       TAG
        |
        ;

headline_body:  headline_body literal_text
        |       headline_body list
//                      |       headline_body drawer
        ;

literal_text:   literal_text WHITESPACE
        |       literal_text WORD
        |       literal_text ENDLN
        ;

list:           list entry
        |       entry
        ;

entry:          singleton
        |       INDENT list DEDENT
        ;

singleton:      MARKER list_text
        |       MARKER ENDLN
        |       MARKER
        ;

list_text:      list_text WORD
        |       list_text WHITESPACE
        |       list_text ENDLN
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
