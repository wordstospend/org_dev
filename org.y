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

todoNode * todo(char * state, char * whitespace) {
    todoNode *node;
    /* allocate node */
    if ((node = (todoNode*)malloc(sizeof(todoNode))) == NULL)
        {
            yyerror("out of memory");
        }
    node->todo = (char*)malloc(sizeof(strlen(state)+1));
    if (node->todo == NULL)
        yyerror("out of memory");
    strcpy(state, node->todo);

    if (whitespace != NULL) {
        node->whitespace = (char*)malloc(sizeof(strlen(whitespace) + 1));
        if (node->whitespace == NULL)
            yyerror("out of memory");
        strcpy(whitespace, node->whitespace);
    }
    return node;
}

priorityNode * priority(char * state, char * whitespace) {
    priorityNode *node;
    /* allocate node */
    if ((node = (priorityNode*)malloc(sizeof(priorityNode))) == NULL)
        {
            yyerror("out of memory");
        }
    node->priority = (char*)malloc(sizeof(strlen(state)+1));
    if (node->priority == NULL)
        yyerror("out of memory");
    strcpy(state, node->priority);

    if (whitespace != NULL) {
        node->whitespace = (char*)malloc(sizeof(strlen(whitespace) + 1));
        if (node->whitespace == NULL)
            yyerror("out of memory");
        strcpy(whitespace, node->whitespace);
    }
    return node;
}

titleNode * title(char * state, char * whitespace) {
    titleNode *node;
    /* allocate node */
    if ((node = (titleNode*)malloc(sizeof(titleNode))) == NULL)
        {
            yyerror("out of memory");
        }
    node->title = (char*)malloc(sizeof(strlen(state)+1));
    if (node->title == NULL)
        yyerror("out of memory");
    strcpy(state, node->title);

    if (whitespace != NULL) {
        node->whitespace = (char*)malloc(sizeof(strlen(whitespace) + 1));
        if (node->whitespace == NULL)
            yyerror("out of memory");
        strcpy(whitespace, node->whitespace);
    }
    return node;
}

tagNode * tag(char * state, char * whitespace) {
    tagNode * node;
    /* allocate node */
    if ((node = (tagNode*)malloc(sizeof(tagNode))) == NULL)
        {
            yyerror("out of memory");
        }

    node->tagsNode = NULL;

    node->tag = (char*)malloc(sizeof(strlen(state)+1));
    if (node->tag == NULL)
        yyerror("out of memeory");
    strcpy(state, node->tag);
    if (whitespace != NULL)
        {
            node->whitespace = (char*)malloc(sizeof(strlen(whitespace) + 1));
            if (node->whitespace == NULL)
                yyerror("out of memory");
            strcpy(whitespace, node->whitespace);
        }
    return node;
}

tagNode * tags(tagNode* tagList, char* state, char* whitespace) {
    tagNode * node = tag(state, whitespace);
    tagList->tagsNode = node;
    return tagList;
}

headlineNode * headline(int stars, todoNode * todo, priorityNode * priority,
                        titleNode * title, tagNode * tags ) {
    headlineNode * node;
    /* allocate node */
    if ((node = (headlineNode*)malloc(sizeof(headlineNode))) == NULL)
        {
            yyerror("out of memory");
        }
    node->stars = stars;
    node->todo = todo;
    node->priority = priority;
    node->title = title;
    node->tags = tags;
    return node;
}

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
