all :	lang

syntax : lexic	lang.y
	bison -v -y  -d  lang.y
lexic : lang.l
	flex lang.l

lang		:	syntax Table_des_symboles.c Table_des_chaines.c Attribute.c PCode/PCode.o
	gcc -o lang lex.yy.c y.tab.c PCode/PCode.o Attribute.c Table_des_symboles.c Table_des_chaines.c

clean		:	
	rm -f lex.yy.c *.o y.tab.h y.tab.c lang *~ y.output; cd PCode; make clean

