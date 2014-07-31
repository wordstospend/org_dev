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

quote_block_begin ^[:blank:]*#\+BEGIN_QUOTE
quote_block_end  ^[:blank:]*#\+END_QUOTE
comment_block_begin ^[:blank:]*#\+BEGIN_COMMENT
comment_block_end  ^[:blank:]*#\+END_COMMENT
example_block_begin ^[:blank:]*#\+BEGIN_EXAMPLE
example_block_end  ^[:blank:]*#\+END_EXAMPLE
verse_block_begin ^[:blank:]*#\+BEGIN_VERSE
verse_block_end  ^[:blank:]*#\+END_VERSE
src_block_begin ^[:blank:]*#\+BEGIN_SRC
src_block_end  ^[:blank:]*#END_SRC
special_block_begin ^[:blank:]*#\+BEGIN_[^[:blank:]]+
special_block_end  ^[:blank:]*#\+END_[^[:blank:]]+
dynamic_block_begin ^[:blank:]*#\+BEGIN:[:blank:]+[^[:blank:]]+
dynamic_block_end ^[:blank:]*#END
dynamic_block_param :[^[:blank:]]+[:blank:]+[^:][^[:blank:]]*

headline_begin ^\*+
drawer_begin ^[:blank:]*:(PROPERTIES|CLOCK|LOGBOOK|RESULT):[:blank:]*$
drawer_end ^[:blank:]*:END:[:blank:]*$


blankLines (^[[:blank:]\t]*\n)+
todo (TODO|IN-PROGRESS|WAITING|DONE|CANCELLED)
priority \[#[a-zA-Z]\]
tags :([A-Za-z0-9_@#%]+:)+
tag :[A-Za-z0-9_@#%]+:
word [^\n[:blank:]]*
whitespace [[:blank:]]*

%%
{headline_begin} {
    yylval.ival = yyleng;
    BEGIN(headline);
    return HEADLINE_BEGIN;
}

<headline>\n {
    BEGIN(0);
 }

<*>{word} {
    yylval.sval = strdup(yytext);
    return WORD;
}

<headline>[[:blank:]]+ {
    yylval.sval = strdup(yytext);
    return WHITESPACE;
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

<INITIAL,headline>{word} {
    // word will always be strictly longer than the tags, priorty, or todo if those
    // are not followed by a spaces eg 'DONEIsNotATodoState' where it will match a
    // word rather than a todo because of the length

    yylval.sval = strdup(yytext);
    return WORD;
}





%%
