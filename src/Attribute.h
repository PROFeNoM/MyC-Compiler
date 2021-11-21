/*
 *  Attribute.h
 *
 *  Created by Janin on 10/2019
 *  Copyright 2018 LaBRI. All rights reserved.
 *
 *  Module for a clean handling of attibutes values
 *
 */

#ifndef ATTRIBUTE_H
#define ATTRIBUTE_H

#define MAX_BLOCKS 100

typedef enum {INT, FLOAT} type;

struct ATTRIBUTE {
  char * name;
  int int_val;           // utilise' pour NUM et uniquement pour NUM
  type type_val;

  /* les autres attributs dont vous pourriez avoir besoin sont déclarés ici */
  float float_val;
  int block_number;
  int scope;
  int offset;
  
  int label_number;
  type type_return;  // Type de retour d'un symbole représentant une fonction

};

typedef struct ATTRIBUTE * attribute;

attribute new_attribute ();
/* returns the pointeur to a newly allocated (but uninitialized) attribute value structure */

int get_offset();

int enter_block();
int reset_block();
int get_current_block_number();
int is_attribute_in_block(attribute x);

int get_current_scope();
void increase_scope();
void decrease_scope();


void compiler_error(char* error_msg);

#endif

