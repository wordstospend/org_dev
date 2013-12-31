org.tab.c org.tab.h: org.y
	bison -d org.y

lex.yy.c: org.l org.tab.h
	flex org.l

org: lex.yy.c org.tab.c org.tab.h org_debug.c
	g++-4.2 org.tab.c lex.yy.c org_debug.c -ll -o org-parse

test: org
	prove -l t/parse.t

# the debug version

bison_debug: flex_debug
	bison -d -v org.y

flex_debug: org.l org.tab.h
	flex -d org.l

org_debug:bison_debug flex_debug
	g++-4.2 org.tab.c lex.yy.c -ll -o org-parse

test_debug: org_debug
	prove -l t/parse.t
