SRC_DIR = ./src
PCODE_DIR = $(SRC_DIR)/PCode
TEST_DIR = ./test
TEST_SOURCES = $(shell find ./test -type f -name "*.myc" -printf "%f\n")
all :	myc

syntax : lexic	$(SRC_DIR)/lang.y
	bison -v -y  -d  $(SRC_DIR)/lang.y
lexic : $(SRC_DIR)/lang.l
	flex $(SRC_DIR)/lang.l

$(PCODE_DIR)/PCode.o : $(PCODE_DIR)/PCode.c $(PCODE_DIR)/PCode.h
	cd $(PCODE_DIR); make pcode
myc		:	syntax $(SRC_DIR)/Table_des_symboles.c $(SRC_DIR)/Table_des_chaines.c $(SRC_DIR)/Attribute.c $(PCODE_DIR)/PCode.o
	gcc -o myc lex.yy.c y.tab.c $(PCODE_DIR)/PCode.o $(SRC_DIR)/Attribute.c $(SRC_DIR)/Table_des_symboles.c $(SRC_DIR)/Table_des_chaines.c -I$(SRC_DIR)

%.myc:	${TEST_DIR}/$@
	./compil.sh ${TEST_DIR}/$@

test: myc $(TEST_SOURCES)

clean		:
	rm -f lex.yy.c *.o y.tab.h y.tab.c myc *~ y.output; find ./test -type f ! -name "*.myc" -delete; cd $(PCODE_DIR); make clean