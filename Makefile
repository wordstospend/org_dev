org.tab.c org.tab.h: org.y
	bison -d org.y

lex.yy.c: org.l org.tab.h
	flex org.l

org: lex.yy.c org.tab.c org.tab.h
	g++ org.tab.c lex.yy.c -ll -o org-parse

test: org
	prove -l t/parse.t

bison_debug:
	bison -d -v org.y
