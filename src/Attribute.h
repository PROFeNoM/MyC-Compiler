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
  int scope;
  int offset;
  
  int label_number;
  
  int args_number;
  char* function_name;
  char* type_return;
  int is_func;

  int is_in_func;
  int args_rank;
};

typedef struct ATTRIBUTE * attribute;

attribute new_attribute ();
/* returns the pointeur to a newly allocated (but uninitialized) attribute value structure */

int get_offset();
void reset_offset();

int enter_block();
int reset_block();

int get_current_scope();
void increase_scope();
void decrease_scope();

int new_label();

void increase_args_rank();
void reset_args_rank();
int get_args_rank(); 

#endif

