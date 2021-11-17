/*
 *  Table des chaines.h
 * 
 *  Created by Janin on 12/10/10.
 *  Copyright 2010 LaBRI. All rights reserved.
 *
 *  This module provide an (implicit) storage capacity
 *  that copy and store each (null terminated) string 
 *  once and only once.
 * 
 *  The adress of the unique copy stored of a given string 
 *  is called the sid (string id) of that string
 * 
 */

#ifndef TABLE_DES_CHAINES_H
#define TABLE_DES_CHAINES_H

/* type used for string id */

typedef char* sid;

/* insert a string into the structure giving back its (unique) sid */
sid string_to_sid(char * s);

/* retreiving (already inserted) string value associated to a given sid */
char * sid_to_string(sid i);

/* check validity of an sid as being present in the strorage structure */
int sid_valid(sid i);

#endif

