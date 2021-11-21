/*
 *  Table des symboles.c
 *
 *  Created by Janin on 12/10/10.
 *  Copyright 2010 LaBRI. All rights reserved.
 *
 */

#include "Table_des_symboles.h"
#include "Attribute.h"

#include <stdlib.h>
#include <stdio.h>

#define MAX_SCOPES 100

/* The storage structure is implemented as a linked chain */

/* linked element def */

typedef struct elem {
	sid symbol_name;
	attribute symbol_value;
	int symbol_scope;
	struct elem * next;
} elem;

/* linked chain initial element */
elem * symbol_tables[MAX_SCOPES] = { NULL };

/* get the symbol value of symb_id from the symbol table */
attribute get_symbol_value(sid symb_id) {
	elem * tracker;

	for (int i = get_current_scope(); i >= 0; i--) {
		tracker = symbol_tables[i];
		/* look into the linked list for the symbol value */
		while (tracker) {
			if (tracker -> symbol_name == symb_id) 
				return tracker -> symbol_value; 
			tracker = tracker -> next;
		}
	}
    
	/* if not found does cause an error */
	fprintf(stderr,"Error : symbol %s is not a valid defined symbol\n",(char *) symb_id);
	exit(-1);
};

/* set the value of symbol symb_id to value */
attribute set_symbol_value(sid symb_id,attribute value) {
	elem * tracker;
	
	/* look for the presence of symb_id in storage, the current scope */
	tracker = symbol_tables[get_current_scope()];
	while (tracker) {
		if (tracker -> symbol_name == symb_id) {
			tracker -> symbol_value = value;
			return tracker -> symbol_value;
		}
		tracker = tracker -> next;
	}
	
	/* otherwise insert it at head of storage with proper value */
	
	tracker = malloc(sizeof(elem));
	tracker -> symbol_name = symb_id;
	tracker -> symbol_value = value;
	tracker -> symbol_scope = get_current_scope();
	tracker -> next = symbol_tables[get_current_scope()];
	symbol_tables[get_current_scope()] = tracker;
	return symbol_tables[get_current_scope()] -> symbol_value;
}

int exists_symbol_value(sid symb_id) {
	for (unsigned int i = 0; symbol_tables[i] != NULL; i++) {
		elem * tracker = symbol_tables[i];
		while (tracker) {
			if (tracker->symbol_name == symb_id)
				return 1;
			tracker = tracker->next;
		}
	}
	return 0;
}

void exit_block() {
	symbol_tables[get_current_scope()] = NULL;
	reset_block();
}

void print_st() {
	for (unsigned int i = 0; symbol_tables[i] != NULL; i++) {
		elem * tracker = symbol_tables[i];
		printf("[%d]", i);
		while (tracker) {
			printf("-> %s", tracker->symbol_name);
			tracker = tracker->next;
		}
		printf("\n");
	}
}