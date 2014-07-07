#include <stdlib.h>
#include <stddef.h>

typedef enum { HEADLINE=0 } nodeType;

typedef struct {
  char * title;
  char * alt_title;
  char * todo_keyword;
  char * todo_type;
  char * priority;
  char ** tags;
  int tag_count;
  int level;

} headline_property;

union Property {
  headline_property headline;

};

typedef struct {
  nodeType type;
  char * raw_contents;
  union Property property;
} org_node;

// each type must have a constructor and destructor that is placed in
// the constructor_dispatch_array and the destructory_dispatch_array

org_node * headline_alloc(org_node * node){
  headline_property * prop = &node->property.headline;
  prop->title = NULL;
  prop->alt_title = NULL;
  prop->todo_keyword = NULL;
  prop->todo_type = NULL;
  prop->priority = NULL;
  prop->tags = NULL;
  prop->tag_count = 0;
  prop->level = 0;
  return node;
}

int headline_free(org_node* node) {
  headline_property prop =  node->property.headline;
  free(prop.title);
  free(prop.alt_title);
  free(prop.todo_keyword);
  free(prop.priority);
  for(int i = 0; i < prop.tag_count; i++){
    free(prop.tags[i]);
  }
  return 1;
}

typedef org_node* (*constructor)(org_node* );
constructor constructor_dispatch_array[1] = {&headline_alloc};

void init_node(org_node* node, nodeType type) {
  node->type = type;
  node->raw_contents = NULL;
  node = (*constructor_dispatch_array[type])(node);
}

org_node * org_node_alloc(nodeType type){
  /* allocate node */
  org_node * node;
  if ((node = (org_node*)malloc(sizeof(org_node))) == NULL)
    {

    }
  else {
    init_node(node, type);
  }
  return node;
}

typedef int (*free_function) (org_node*);
free_function destructor_dispatch_array[1] = { &headline_free};


int org_node_destroy(org_node* node){
  int result = (*destructor_dispatch_array[node->type])(node);
  free(node->raw_contents);
  return result;
}

int org_node_free(org_node* node){
  int result =  org_node_destroy(node);
  free(node);
  return result;
}
