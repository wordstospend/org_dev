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

<headline>{todo}[ \t\n] { // this isn't safe for all systems where newline is weird
    // end of the line means we leave headline state
    if (yytext[yyleng - 1] == '\n') {
        BEGIN(0);
    }

    char *yycopy = strdup( yytext );
    // trim the space from the end
    yycopy[yyleng - 1] = '\0';
    yylval.sval = yycopy;
    free(yycopy);
    return TODO
}

<headline>{priority}[ \t\n] {
    // end of the line means we leave headline state
    if (yytext[yyleng - 1] == '\n') {
        BEGIN(0);
    }

    char *yycopy = strdup( yytext );
    // trim the space from the end
    yycopy[yyleng - 1] = '\0';
    yylval.sval = yycopy;
    free(yycopy);
    return PRIORITY;

}
/// need some way to handle the above two in the case of end of file

<*>{word} {
    yylval.sval = yytext;
    return WORD;
}

<headline>[[:blank:]]+ { yylval.sval = yytext; return WHITESPACE;}

<*>\n {return ENDLN;}

%%
