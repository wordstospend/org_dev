%{
#include <cstdio>
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()
#include "org.h"
#include "org.tab.h"  // to get the token types that we return


%}
%s list
%x headline
%x tag_block
headline_level ^\**[[:blank:]]
blankLines ([[:blank:]\t]*\n)+
section (([^*]|[[:blank:]])+(.*[[:blank:]]*)*\n)+
todo (TODO|IN-PROGRESS|WAITING|DONE|CANCELLED)
priority \[#[a-zA-Z]\]
tags :([A-Za-z0-9_@#%]+:)+
tag :[A-Za-z0-9_@#%]+:
word [^\n[:blank:]]*
whitespace [[:blank:]]*
directive adirctivethatdoesntexist

%%
{headline_level} {
    yylval.ival = yyleng -1;
    BEGIN(headline);
    return STARS ;
}
{section} {
  yylval.sval = strdup(yytext);
  return SECTION;
}

{blankLines} {
    yylval.sval = strdup(yytext);
    return POST_BLANK;
}

<headline>{todo} {
    yylval.sval = strdup(yytext);
    return TODO;
 }

<headline>{priority} {
    yylval.sval = strdup(yytext);
    return PRIORITY;
}

<headline>{tags} {
    BEGIN(tag_block);
    yyless(0);
 }

<headline,tag_block>{tag} {
    //This is a capture of a tag witha trailing ':' which should be placed back
    // on the input stream. Resulting in a trailing ':' after all
    // tags are captured
    yytext[yyleng -1] = '\0';
    yylval.sval = strdup(++yytext);
    unput(':');

    return TAG;
 }

<tag_block>: {
    // this is to capture the trailing context of ':' left at the end of a
    // group of tags
    BEGIN(headline);
 }

<headline>{word} {
    // word will always be strictly longer than the tags, priorty, or todo if those
    // are not followed by a spaces eg 'DONEIsNotATodoState' where it will match a
    // word rather than a todo because of the length

    yylval.sval = strdup(yytext);
    return WORD;
}

<headline>[[:blank:]]+ {
    yylval.sval = strdup(yytext);
    return WHITESPACE;
}

<headline>\n {
    BEGIN(0);
 }

%%
