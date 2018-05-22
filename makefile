test: lex.yy.c grammar.tab.c
	gcc grammar.tab.c lex.yy.c ast.c -o denise

lex.yy.c: grammar.tab.c lexer.l
	lex lexer.l

grammar.tab.c: grammar.y
	bison -d grammar.y

