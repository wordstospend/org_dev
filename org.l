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
%x section_block
%x drawer
%x drawer_key
%x drawer_value
headline_level ^\**[[:blank:]]
blankLines ([[:blank:]\t]*\n)+
 //section ([^*\n]+.*\n)+
section ^[^*\n]+
drawer_start ^[[:blank:]\t]*:(PROPERTIES|CLOCK|LOGBOOK|RESULT):[\t[:blank:]]*$
drawer_end ^[\t[:blank:]]*:END:[\t[:blank:]]*$
drawer_value [^[:blank:]\t]+.*$
drawer_key :[^[:blank:]\t]+:
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
  BEGIN(section_block);
  yyless(0);
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

<headline, drawer>[[:blank:]]+ {
    yylval.sval = strdup(yytext);
    return WHITESPACE;
}

<headline>\n {
    BEGIN(0);
 }

<section_block>{drawer_start} {
    BEGIN(drawer);
    // I want to remove all the extra stuff around the keyword but for now
    yylval.sval = strdup(yytext);
    // not a real thing yet
    return DRAWER_START;
}

<drawer>{drawer_key} {
    BEGIN(drawer_value);
    yylval.sval = strdup(yytext);
    return DRAWER_KEY;
 }

<drawer_value>{value} {
    yylval.sval = strdup(yytext);
    return DRAWER_VALUE;
}
<drawer_value>\n {
    BEGIN(drawer);
}

<drawer>{drawer_end} {
    BEGIN(0);
    return DRAWER_END;
}


%%
