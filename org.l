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
headline_level ^\**[[:blank:]]
todo (TODO|IN-PROGRESS|WAITING|DONE|CANCELLED)
priority \[#[a-zA-Z]\]
tags :([A-Za-z0-9_@#%]*:)+
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
