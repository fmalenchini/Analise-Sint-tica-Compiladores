all:
	bison -d -v def.y
	flex -l def.l
	gcc lex.yy.c def.tab.c arvore.c -o compilador

clean:
	rm *.tab.c *.tab.h compilador