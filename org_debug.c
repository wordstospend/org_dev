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
  fprintf(outputfile, "A simpletest\n");

}

void output_documentNode(FILE * outputfile, documentNode * node) {
    fprintf(outputfile, "(DOCUMENT ");
    if (node->headline != NULL) {
        output_headline(outputfile, node->headline);
    }
    if (node->doc != NULL) {
        output_documentNode(outputfile, node->doc);
    }
    fprintf(outputfile, ")");
}

void output_headline(FILE * outputfile, headlineNode * node) {
    fprintf(outputfile, "(HEADLINE (STARS %i) ", node->stars);
    if (node->todo != NULL) {
        output_todoNode(outputfile, node->todo);
    }
    if (node->priority != NULL){
        output_priorityNode(outputfile, node->priority);
    }
    if (node->title != NULL){
        output_titleHeadNode(outputfile, node->title);
    }
    if (node->tags != NULL){
        output_tagNode(outputfile, node->tags);
    }
    fprintf(outputfile, ")");
}

void output_todoNode(FILE * outputfile, todoNode * node) {
    fprintf(outputfile, "(TODO ");
    fwrite (node->todo, sizeof(char), strlen(node->todo), outputfile);
    if (node->whitespace != NULL) {
        fprintf(outputfile, " \"");
        fwrite (node->whitespace, sizeof(char),
                strlen(node->whitespace), outputfile);
        fprintf(outputfile,"\") ");
    }
    else {
        fprintf(outputfile, ")");
    }
}

void output_priorityNode(FILE * outputfile, priorityNode * node) {
    fprintf(outputfile, "(PRIORITY ");
    fwrite(node->priority, sizeof(char), strlen(node->priority), outputfile);
    if (node->whitespace != NULL) {
        fprintf(outputfile, " \"");
        fwrite (node->whitespace, sizeof(char),
                strlen(node->whitespace), outputfile);
        fprintf(outputfile,"\") ");
    }
    else {
        fprintf(outputfile, ")");
    }
}

void output_tagNode(FILE * outputfile, tagNode * node) {
    fprintf(outputfile, "(TAGS ");
    fwrite(node->tag, sizeof(char), strlen(node->tag), outputfile);
    if (node->tagsNode != NULL){
        output_tagNode(outputfile, node->tagsNode);
    }
    if (node->whitespace != NULL) {
        fprintf(outputfile, " \"");
        fwrite (node->whitespace, sizeof(char),
                strlen(node->whitespace), outputfile);
        fprintf(outputfile,"\") ");
    }
    else {
        fprintf(outputfile, ")");
    }
}

void output_titleNode(FILE * outputfile, titleNode * node) {
    fwrite(node->word, sizeof(char), strlen(node->word), outputfile);
    if (node->nextword != NULL) {
        output_titleNode(outputfile, node->nextword);
    }
}

void output_titleHeadNode(FILE * outputfile, titleHeadNode * node) {
    fprintf(outputfile, "(TITLE \"");
    fwrite(node->word, sizeof(char), strlen(node->word), outputfile);
    if (node->nextword != NULL) {
        output_titleNode(outputfile, node->nextword);
    }
    fprintf(outputfile, "\")");
}
