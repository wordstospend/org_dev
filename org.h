typedef enum { } nodeType;

/* todo */
typedef struct {
    char * todo;
    // this can be void and only exist in the case that todo has space following
    // it
    char * whitespace;
} todoNode;

/* priority */
typedef struct {
    char * priority;
    // optional
    char * whitespace;
} priorityNode;

/* title */

typedef struct titleNodeStruct {
    char * word;
    struct titleNodeStruct * nextword;
} titleNode;

typedef struct titleHeadStruct {
    char * word;
    titleNode * nextword;
    titleNode * endword;
} titleHeadNode;;

/* tags */
typedef struct tagNodeStruct {
    char * tag;
    char * whitespace;
    struct tagNodeStruct * tagsNode;
} tagNode;


/* headline */
typedef struct {
    int stars;
    // optional
    todoNode * todo;
    priorityNode * priority;
    titleHeadNode * title;
    tagNode * tags;
} headlineNode;

/* document - a linked list of headline */
typedef struct documentNodeStruct {
  headlineNode * headline;
  documentNodeStruct * doc;
} documentNode;
