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
%x tags
headline_level ^\**[[:blank:]]
todo (TODO|IN-PROGRESS|WAITING|DONE|CANCELLED)
priority \[#[a-zA-Z]\]
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

<headline>{todo} {
    yylval.sval = yytext;
    return TODO;
 }

<headline>{priority} {
    yylval.sval = yytext;
    return PRIORITY;
}

<headline,tags>{tag} {
    //This is a capture of a tag witha trailing ':' which should be placed back
    // on the input stream. Resulting in a trailing ':' after all
    // tags are captured
    BEGIN(tags);
    yyless(yyleng - 1);
    yyleng =- 1;
    yylval.sval = yytext++;

    return TAG;
 }

<tags>: {
    // this is to capture the trailing context of ':' left at the end of a
    // group of tags
    BEGIN(headline);
 }

<headline>{word} {
    // word will always be strictly longer than the tags, priorty, or todo if those
    // are not followed by a spaces eg 'DONEIsNotATodoState' where it will match a
    // word rather than a todo because of the length

    yylval.sval = yytext;
    return WORD;
}

<headline>[[:blank:]]+ {
    yylval.sval = yytext;
    return WHITESPACE;
}

<headline>\n {
    BEGIN(0);
 }

%%
