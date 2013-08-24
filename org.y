%{
#include <cstdio>
#include <iostream>
using namespace std;

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
%token <ival> HEADLINE_INDENT
%token <sval> PRIORITY
%token <sval> WORD
%token <sval> TAG
%token <sval> WHITESPACE
%token <sval> HEADLINE_FULL_TEXT

%%

headline:
                HEADLINE_INDENT headline_body {
                printf("indent %d", $1 );
                cout << endl;
                }
                ;
headline_text:
                headline_text WORD {
                    cout << "WORD '" << $2 << "'" << endl;
                }
        |       WORD {
                cout << "WORD '" << $1 << "'" << endl;
                 }
        |       headline_text WHITESPACE {
                cout << "SPACE" << endl;
                 }
         |       WHITESPACE {
                 cout << "SPACE" << endl;
                 }
                 ;
headline_body:
                 PRIORITY headline_text tags {
                 cout << "found a healine: with priority"<< endl;
                 }
         |       headline_text tags {
                 cout << "found a headline: with text  "<< endl;
                 }
         |       PRIORITY tags {
                 cout << "found a headline free of text" << endl;
                 }
         |       tags { cout << "found headline free text and priority" << endl; }
                 ;
tags:
                 tags TAG ENDLN { cout << "found a tag >" << $2 << endl;}
         |       TAG ENDLN { cout << "found a tag <" << $1 << endl;}
         |       ENDLN {cout << "end of the line" << endl;}
                ;
%%

main() {
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
