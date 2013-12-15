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
typedef struct {
    char * title;
    // optional
    char * whitespace;
} titleNode;

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
    titleNode * title;
    tagNode * tags;
} headlineNode;
