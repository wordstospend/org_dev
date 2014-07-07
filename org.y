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
documentNode * document(documentNode * doc, headlineNode * headline);
sectionNode * section(char * body);
documentNode * apendToLastChild(documentNode * doc, char * blankSpace);
documentNode * documentFromSection(documentNode *doc, char * sectionString);

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
%token <sval> TODO
%token <sval> DRAWER_START
%token <sval> DRAWER_KEY
%token <sval> DRAWERVALUE
%token <sval> DRAWER_END
%token <sval> BLANK_LINES

%type <ptodo> todo_keyword
%type <pdoc> doc //     doc2
%type <ppriority> priority
%type <ptitle> title
%type <ptags> tags
%type <pheadline> headline
%type <sval> section

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
        |       doc BLANK_LINES { $$ = apendToLastChild($1,$2); }
        |       section { $$ = documentFromSection(NULL, $1); }
        |       doc section { $$ = documentFromSection($1, $2); }
        ;
// The last 2 rules allow for an impossible scenario of a section followed by a section
// this will mean that it is gramaticly possible, but it is not in fact lexically possible

// as of right now this is not very complicated
section:        SECTION {
    printf("section\n");
     $$ = $1;
 }
        ;

// section_children is the set of all possible children of a section
// all unimplemented have been commented
section_children: section_children block
        |       section_children drawer
        |       section_children plain-list
        |       section_children paragraph
        //      TBC     |       section_children fooonote_definition
        //      TBC     |       section_children inlinetask
        |
        ;


block:          BLOCK_BEGIN_A block_content_optional BLOCK_BEGIN_B block_content_optional BLOCK_END_A
                // the case where block b is incomplete
        |       BLOCK_BEGIN_A block_content_optional BLOCK_END_A
        |       BLOCK_BEGIN_B block_content_optional BLOCK_END_B
        ;

paragraph:      BLOCK_BEGIN_A block_content_optional BLOCK_BAD_END
                // This is the case where block A is invalid because the section has ended. It may be advisible for
                // this instead to be a generic section end token.
        ;

block_content_optional:
                block_content_optional drawer
        |       block_content_optional plain-list
        |       block_content_optional paragraph
        //      TBC     |       block_content_optional fooonote_definition
        //      TBC     |       block_content_optional inlinetask
        |
        ;


paragraph:
drawer:         DRAWER_START drawer_content DRAWER_END { // do something here }
        ;

drawer_content: drawer_content paragraph
        |       drawer_content key_value
        ;

key_value:      DRAWER_KEY WHITESPACE drawer_value
        ;
// any number of words and white space without a newline
drawer_value:   WORD
        |
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

tags:   tags TAG WHITESPACE { printf("WTF a tag? %s \"%s\"",$2, $3); $$ = tags($1, $2, $3); }
        |       tags TAG { printf("tag retrieved %s\n", $2);$$ = tags($1, $2, NULL); }
        |      /*empty */ { printf("empty tag fired\n"); $$ = NULL; }
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

    node->nextTagNode = NULL;
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
    if (tagList == NULL) {
        printf("returning the single tag %s\n", node->tag);
        return node;
    }
    else {
        tagNode * lastNode = tagList;
        while(lastNode->nextTagNode != NULL) {
            lastNode = lastNode->nextTagNode;
        }
        lastNode->nextTagNode = node;
        return tagList;
    }

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
    node->postBlank = NULL;
    node->section = NULL;
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
        doc->leadingSection = NULL;

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
        else if (headline->stars == doc->currentChild->stars) {
            // we found our sibling
            printf("insert headline as sibling\n");
            doc->currentChild->sibling = headline;
            headline->parent = doc->currentChild->parent;
            doc->currentChild = headline;

        }
        else if (headline->stars < doc->currentChild->stars) {
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


sectionNode * section(char * body) {
  sectionNode * sec = (sectionNode*)malloc(sizeof(sectionNode));
  if (sec == NULL) {
    yyerror("out of memory");
  }
  else {
    sec->body = body;
    sec->postBlank = NULL;
    return sec;
  }
}

documentNode * apendToLastChild(documentNode * doc, char * blankSpace) {
    printf("post apendToLastChild\n");
    doc->currentChild->postBlank = blankSpace;
    return doc;
}


documentNode * documentFromSection(documentNode *doc, char * sectionString) {
    if (doc == NULL ) {
        printf("allocate Document for section\n");
        /* allocate node */

        if ((doc = (documentNode*)malloc(sizeof(documentNode))) == NULL)
            {
                yyerror("out of memory");
            }
        sectionNode * sec = section(sectionString);
        doc->leadingSection = sec;
        doc->firstChild = NULL;
        doc->currentChild = NULL;
    }
    else {
      printf("adding section to doc\n");
      printf("section \"%s\"\n", sectionString);
      sectionNode * sec = section(sectionString);
      doc->currentChild->section = sec;
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
