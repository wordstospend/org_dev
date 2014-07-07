


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
    struct tagNodeStruct * nextTagNode;
} tagNode;


/* section
   In the future this will be a more complete model
   as of right now it just needs to be a string
*/
typedef struct {
    char * body;
    char * postBlank;
} sectionNode;


/* headline */
typedef struct headlineNodeStruct {
    int stars;
    // optional
    todoNode * todo;
    priorityNode * priority;
    titleHeadNode * title;
    tagNode * tags;
    char * postBlank;
    // headline relationships
    headlineNodeStruct * parent;
    headlineNodeStruct * child;
    headlineNodeStruct * sibling;
    // section
    sectionNode * section;
} headlineNode;

/* document - a linked list of headline */
typedef struct documentNodeStruct {
    sectionNode * leadingSection;
    headlineNode * firstChild;
    headlineNode * currentChild;
} documentNode;
