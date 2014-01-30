#include <stdio.h>
#include <string.h>

#include "org.h"
#include "org.tab.h"

// forward declaration so I can work in the order I feel like
void output_documentNode(FILE * outputfile, documentNode * node);
void output_headline(FILE * outputfile, headlineNode * node);
void output_priorityNode(FILE * outputfile, priorityNode * node);
void output_tagNode(FILE * outputfile, tagNode * node);
void output_titleNode(FILE * outputfile, titleNode * node);
void output_titleHeadNode(FILE * outputfile, titleHeadNode * node);
void output_todoNode(FILE * outputfile, todoNode * node);


void output_ast(FILE * outputfile, documentNode * node) {

  printf("a simple test of ast output\n");
  output_documentNode(outputfile, node);

}

void output_documentNode(FILE * outputfile, documentNode * node) {
    printf("documentNode\n");
    fprintf(outputfile, "(DOCUMENT");
    headlineNode * child = node->firstChild;
    while (child != NULL) {
        fprintf(outputfile, " ");
        output_headline(outputfile, child);
        child = child->sibling;
    }
    fprintf(outputfile, ")\n");
}

void output_headline(FILE * outputfile, headlineNode * node) {
    printf("headline\n");
    fprintf(outputfile, "(HEADLINE (STARS %i)", node->stars);
    if (node->todo != NULL) {
        fprintf(outputfile, " ");
        output_todoNode(outputfile, node->todo);
    }
    if (node->priority != NULL){
        fprintf(outputfile, " ");
        output_priorityNode(outputfile, node->priority);
    }
    if (node->title != NULL){
        fprintf(outputfile, " ");
        output_titleHeadNode(outputfile, node->title);
    }
    if (node->tags != NULL){
        fprintf(outputfile, " (TAGS ");
        output_tagNode(outputfile, node->tags);
        fprintf(outputfile, ")");
    }
    headlineNode * child = node->child;
    while (child != NULL) {
        fprintf(outputfile, " ");
        output_headline(outputfile, child);
        child = child->sibling;
    }
    fprintf(outputfile, ")");
}

void output_todoNode(FILE * outputfile, todoNode * node) {
    printf("todoNode\n");
    fprintf(outputfile, "(TODO ");
    fwrite (node->todo, sizeof(char), strlen(node->todo), outputfile);
    if (node->whitespace != NULL) {
        fprintf(outputfile, " \"");
        fwrite (node->whitespace, sizeof(char),
                strlen(node->whitespace), outputfile);
        fprintf(outputfile,"\")");
    }
    else {
        fprintf(outputfile, ")");
    }
}

void output_priorityNode(FILE * outputfile, priorityNode * node) {
    printf("priorityNode\n");
    fprintf(outputfile, "(PRIORITY ");
    fwrite(node->priority, sizeof(char), strlen(node->priority), outputfile);
    if (node->whitespace != NULL) {
        fprintf(outputfile, " \"");
        fwrite (node->whitespace, sizeof(char),
                strlen(node->whitespace), outputfile);
        fprintf(outputfile,"\")");
    }
    else {
        fprintf(outputfile, ")");
    }
}

void output_tagNode(FILE * outputfile, tagNode * node) {
    printf("tagNode %s\n", node->tag);
    fwrite(node->tag, sizeof(char), strlen(node->tag), outputfile);
    if (node->nextTagNode != NULL){
      fprintf(outputfile, " ");
      output_tagNode(outputfile, node->nextTagNode);
    }
    if (node->whitespace != NULL) {
      printf("whitespace \"%s\"", node->whitespace);
        fprintf(outputfile, " \"");
        fwrite (node->whitespace, sizeof(char),
                strlen(node->whitespace), outputfile);
        fprintf(outputfile,"\"");
    }
}

void output_titleNode(FILE * outputfile, titleNode * node) {
    printf("titleNode\n");
    printf("word \"%s\" %zu\n", node->word, strlen(node->word));
    fwrite(node->word, sizeof(char), strlen(node->word), outputfile);
    if (node->nextword != NULL) {
        output_titleNode(outputfile, node->nextword);
    }
}

void output_titleHeadNode(FILE * outputfile, titleHeadNode * node) {
    printf("titleHeadNode\n");
    fprintf(outputfile, "(TITLE \"");
    fwrite(node->word, sizeof(char), strlen(node->word), outputfile);
    if (node->nextword != NULL) {
        output_titleNode(outputfile, node->nextword);
    }
    fprintf(outputfile, "\")");
}
