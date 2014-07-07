
#include "node.h"

int main (void)
{
  org_node * a_headline = org_node_alloc(HEADLINE);
  org_node_free(a_headline);
}
