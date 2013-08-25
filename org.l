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
priority \[#[a-zA-Z]\]([[:blank:]]|\n)
tags :([A-Za-z0-9_@#%]*:)+
word [^\n[:blank:]]*
whitespace [[:blank:]]*

      // just a thought
list ([0-9]+\.|\))|[+*]
%%
{headline_level} {
    yylval.ival = yyleng -1;
    BEGIN(headline);
    return HEADLINE_INDENT ;
 }

<headline>{priority} {
    yylval.sval = yytext;
    return PRIORITY;
 }

<headline>{tags} {
    int i = 1;
    char *yycopy = strdup( yytext );
    for (; i < yyleng; i ++) {
        if (yytext[i] == ':') {
            // if this is the last char then this is the last tag in the group
            // and we don't need to add the colon back
            if (i == yyleng-1) {
                yycopy = strdup( yytext );
            }
            // place everything back accept our tag eg :thetag:
            else {
                yyless(i+2);
                yycopy = strdup( yytext );
                // put back the trailing colon
                yyless(i+1);
            }

            break;
        }
    }
    // now lets trim the colon's eg :thetag:
    yycopy[i+1] = '\0'; // back colon :thetag
    yylval.sval = yycopy+1; // front thetag
    free( yycopy );
    return TAG;
        }

<*>{word} {
    yylval.sval = yytext;
    return WORD;
 }

<*>[[:blank:]]+ { yylval.sval = yytext; return WHITESPACE;}
<headline>[\n] { BEGIN(0); return ENDLN;}


%%
