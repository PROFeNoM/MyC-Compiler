/*
 *  Table des chaines.c
 *
 *  Created by Janin on 12/10/10.
 *  Copyright 2010 LaBRI. All rights reserved.
 *
 */

#include "Table_des_chaines.h"
#include <stdlib.h>
#include <string.h>

/* good old string copy function with malloc */

char * string_copy(char *s) {
	if (!s) return NULL;
	char * sc = malloc(strlen(s)*sizeof(char));
	return strcpy(sc, s);
}

/* The storage structure is implemented as a linked chain.
   A more efficient structure would be (why so ?) a hash table  */

/* linked element def */

typedef struct elem {
	char * value;
	struct elem * next;
} elem;

/* linked chain initial element */
static elem * storage=NULL;

/* insert a string into the storage structure giving back its (unique) sid */
sid string_to_sid(char * s) {
	
	elem * tracker;

	/* check s is a real string */
	if (!s) return NULL;
	
	
	/* look for the presence of s in storage  and returns its copy if there */
	
	tracker = storage;
	while (tracker) {
		if (!strcmp(tracker->value, s)) return tracker->value;
		tracker = tracker -> next;
	}
	
	/* otherwise insert it at head of storage */
	
	tracker = malloc(sizeof(elem));
	tracker -> value = string_copy(s);
	tracker -> next = storage;
	storage = tracker;
	return storage -> value;
}

/* check the validity of an sid as being present in the strorage structure */
int sid_valid(sid i) {
	elem * tracker=storage;
	while (tracker) {
		if (tracker->value==i) return 1;
		tracker=tracker->next;
	}
	return 0;
}

