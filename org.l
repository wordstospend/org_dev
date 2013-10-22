%{
#include <cstdio>
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

#include "org.tab.h"  // to get the token types that we return

%}
%s list
%x headline
headline_level ^\**[[:blank:]]
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

<*>{word} {
    yylval.sval = yytext;
    return WORD;
}

<headline>[[:blank:]]+ { yylval.sval = yytext; return WHITESPACE;}


%%
