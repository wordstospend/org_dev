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

todoNode * todo(char * state, char * whitespace);
priorityNode * priority(char * state, char * whitespace);
titleHeadNode * title(titleHeadNode * headNode, char * word);
tagNode * tag(char * state, char * whitespace);
tagNode * tags(tagNode* tagList, char* state, char* whitespace);
headlineNode * headline(int stars, todoNode * todo, priorityNode * priority,
                        titleHeadNode * title, tagNode * tags );
 documentNode * document(documentNode * doc,headlineNode * headline);
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
    todoNode *ptodo;
    priorityNode *ppriority;
    titleHeadNode *ptitle;
    tagNode *ptags;
    headlineNode *pheadline;
    documentNode *pdoc;
};

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
%token <sval> BLOCK /* The block of text following a list item. Where each line
must have an indention to match the first character of the first */

%type <ptodo> todo_keyword
%type <pdoc> doc //     doc2
%type <ppriority> priority
%type <ptitle> title
%type <ptags> tags
%type <pheadline> headline

%%

document:       doc      {
  if (astFile != NULL) {
                printf("calling output_ast\n");
                output_ast(astFile, $1);
                }
                exit(0);
                }
      ;

doc:            headline { $$ = document(NULL, $1); }
        |       doc headline { $$ = document($1, $2); }
        ;

headline:       STARS todo_keyword priority title tags
                {
                    $$ = headline($1, $2, $3, $4, $5);
                }
        ;

todo_keyword:   TODO WHITESPACE { $$ = todo($1, $2); }
        |       TODO { $$ = todo($1, NULL); }
        |       /* empty */ { $$ = NULL; }
        ;

priority:       PRIORITY WHITESPACE { $$ = priority($1, $2); }
        |       PRIORITY { $$ = priority($1, NULL); }
        |       /* empty */ { $$ = NULL; }
        ;

title:          title WORD {printf("word %s\n", $2); $$ = title($1, $2); }
        |       title WHITESPACE { printf("whitespace \"%s\"\n", $2); $$ = title($1, $2); }
|       WORD { printf("word %s\n", $1); $$ = title(NULL, $1); }
        ;

/*title:         TITLE /* a headline is treated differently if the first word of the
               title is a org-comment-string
               if the title is org-footnote-section it will be considered a footnote
               section. I don't know how I'm going to handle this yet. Is this part
               of the parsing, or the lexing? */
  //      |      /* empty */
    //    ;

tags:           tags TAG WHITESPACE { printf("WTF a tag? %s \"%s\"",$2, $3); $$ = tags($1, $2, $3); }
|       tags TAG { printf("tag retrieved %s\n", $2);$$ = tags($1, $2, NULL); }
        |      /*empty */ { $$ = NULL; }
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
    node->todo = NULL;
    node->whitespace = NULL;

    node->todo = state;
    if (whitespace != NULL) {
        node->whitespace = whitespace;
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
    node->priority = NULL;
    node->whitespace = NULL;

    node->priority = state;
    if (whitespace != NULL) {
        node->whitespace = whitespace;
    }
    return node;
}

titleHeadNode * title(titleHeadNode * headNode, char * word) {
    if (headNode == NULL) {
        titleHeadNode * node;
        if ((node = (titleHeadNode*)malloc(sizeof(titleHeadNode))) == NULL)
            {
                yyerror("out of memeory");
            }
        node->word = word;
        printf("What word did I get\"%s\" %zu\n", node->word, strlen(node->word));
        node->nextword = NULL;
        node->endword = NULL;
        return node;
    }
    else {
        titleNode *node;
        /* allocate node */
        if ((node = (titleNode*)malloc(sizeof(titleNode))) == NULL)
            {
            yyerror("out of memory");
        }
        node->nextword = NULL;
        node->word = word;

        printf("What word did I get\"%s\" %zu\n", node->word, strlen(node->word));
        if (headNode->endword == NULL) {
            headNode->nextword = node;
        }
        else {
            headNode->endword->nextword = node;
        }

        headNode->endword = node;
        return headNode;
    }

}

tagNode * tag(char * state, char * whitespace) {
    tagNode * node;
    /* allocate node */
    if ((node = (tagNode*)malloc(sizeof(tagNode))) == NULL) {
            yyerror("out of memory");
    }

    node->tagsNode = NULL;
    node->whitespace = NULL;
    node->tag = NULL;

    node->tag = state;
    if (whitespace != NULL) {
            node->whitespace = whitespace;

    }

    return node;
}

tagNode * tags(tagNode* tagList, char* state, char* whitespace) {
    tagNode * node = tag(state, whitespace);
    if (tagList == NULL); {
      return node;
    }
    tagList->tagsNode = node;
    return tagList;
}

headlineNode * headline(int stars, todoNode * todo, priorityNode * priority,
                        titleHeadNode * title, tagNode * tags ) {
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
    node->parent = NULL;
    node->child = NULL;
    node->sibling = NULL;
    return node;
}

documentNode * document(documentNode * doc, headlineNode * headline ) {
    if (doc == NULL) {
        printf("allocate Document\n");
        /* allocate node */
        if ((doc = (documentNode*)malloc(sizeof(documentNode))) == NULL)
            {
                yyerror("out of memory");
            }
        doc->firstChild = headline;
        doc->currentChild = headline;
    }
    else {
        printf("insert headline in Document\n");
        if ( headline->stars > doc->currentChild->stars) {
            // we found our parent
            printf("insert headline as child\n");
            doc->currentChild->child = headline;
            headline->parent = doc->currentChild;
            doc->currentChild = headline;
        }
        if (headline->stars == doc->currentChild->stars) {
            // we found our sibling
            printf("insert headline as sibling\n");
            doc->currentChild->sibling = headline;
            headline->parent = doc->currentChild->parent;
            doc->currentChild = headline;

        }
        if (headline->stars < doc->currentChild->stars) {
            // we could have found either our sibling or desendent
            if (doc->currentChild->parent == NULL ||
                doc->currentChild->parent->stars < headline->stars) { // sibling
                printf("insert headline as null or <\n");
                doc->currentChild->sibling = headline;
                headline->parent = doc->currentChild->parent;
                doc->currentChild = headline;
            }
            else {
                printf("insert with recursive call\n");
                doc->currentChild = doc->currentChild->parent;
                doc = document(doc, headline);
            }
        }
    }
    return doc;
}

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

        yydebug = 1;

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
