#include "Attribute.h"

#include <stdio.h>
#include <stdlib.h>

attribute new_attribute () {
  attribute r;
  r  = malloc (sizeof (struct ATTRIBUTE));
  return r;
};

int block_count = 0;
int queue_block[MAX_BLOCKS] = { 0 };
int queue_block_p = 0;

int get_current_block_number(){
  return queue_block[queue_block_p];
};

int enter_block(){
  queue_block[++queue_block_p] = ++block_count;
  increase_scope();
  return get_current_block_number();
};

int reset_block(){
  queue_block_p--;
  decrease_scope();
  return get_current_block_number();
};

int offsets[MAX_BLOCKS] = { 0 };
int get_offset() 
{
	return offsets[get_current_block_number()]++;
}
void reset_offset()
{
  offsets[get_current_block_number()] = 0;
}

int scope_level = 0;
int get_current_scope() {
    return scope_level;
}

void increase_scope() {
    scope_level++;
}

void decrease_scope() {
    scope_level--;
}

int label_count = 0;
int new_label() {
    return label_count++;
}

int args_rank_count = 1;
void increase_args_rank() {
    args_rank_count++;
}
void reset_args_rank() {
    args_rank_count = 1;
}
int get_args_rank() {
    return args_rank_count;
}
