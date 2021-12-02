%{

#include "Table_des_symboles.h"
#include "Attribute.h"
#include "PCode/PCode.h"

#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

extern int yylex();
extern int yyparse();

void yyerror (char* s) {
  printf ("%s\n",s);
}

void compiler_error(const char* error_msg, ...) {
    va_list args;
    fprintf(stderr, "Error: ");
    va_start(args, error_msg);
    vfprintf(stderr, error_msg, args);
    va_end(args);
    exit(-1);
}
		

%}

%union { 
	struct ATTRIBUTE * att;
}

%token <att> NUM
%token TINT
%token <att> ID
%token AO AF PO PF PV VIR
%token RETURN VOID EQ
%token <att> IF ELSE WHILE

%token <att> AND OR NOT DIFF EQUAL SUP INF SUPEQ INFEQ
%token PLUS MOINS STAR DIV
%token DOT ARR

%left OR                                  // higher priority on ||
%left AND                                 // higher priority on &&
%left DIFF EQUAL SUP INF SUPEQ INFEQ      // higher priority on comparison
%left PLUS MOINS                          // higher priority on + - 
%left STAR DIV                            // higher priority on * /
%left DOT ARR                             // higher priority on . and -> 
%nonassoc UNA                             // highest priority on unary operator
%nonassoc ELSE


%start prog  

// liste de tous les non terminaux dont vous voulez manipuler l'attribut
%type <att> exp  typename  type  vlist  cond  if  bool_cond  inst  elsop  else  
%type <att> loop  while_cond  while  params  arglist  fun_head  args  app
         

%%

prog : func_list               {}
;

func_list : func_list fun      {}
| fun                          {}
;


// I. Functions

fun : fun_type fun_head fun_body        {reset_args_rank(); }
;

fun_type: type                 {}

fun_head : ID PO PF            {
                                $1->type_val = $<att>0->type_val;
                                $1->args_number = 0;
                                $1->is_func = 1;
                                $1->type_return = $<att>0->name;
                                set_symbol_value(string_to_sid($1->name), $1);
                                if (strcmp($1->name, "main"))
                                    printf("void %s_pcode() {\n", $1->name);
                                else {
                                    reset_offset();
                                    printf("int main() {\n");
                                }
                                $$ = $1;} // erreur si profondeur diff zero
| ID PO params PF              {
                                $1->type_val = $<att>0->type_val;
                                $1->args_number = get_args_number();
                                $1->is_func = 1;
                                $1->type_return = $<att>0->name;
                                set_symbol_value(string_to_sid($1->name), $1);
                                if (strcmp($1->name, "main"))
                                    printf("void %s_pcode() {\n", $1->name);
                                else
                                    printf("int main() {\n");
                                reset_args_number();
                                $$ = $1;}
;

params: type ID vir params     {
                                increase_args();
                                $2->type_val = $1->type_val;
                                $2->is_in_func = 1;
                                $2->args_rank = get_args_rank();
                                increase_args_rank();
                                set_symbol_value(string_to_sid($2->name), $2);}
| type ID                      {
                                increase_args();
                                $2->type_val = $1->type_val;
                                $2->is_in_func = 1;
                                $2->args_rank = get_args_rank();
                                increase_args_rank();
                                set_symbol_value(string_to_sid($2->name), $2);}

vlist: vlist vir ID            {
                                $3->type_val = $<att>0->type_val;
                                $3->offset = get_offset(); 
                                $3->scope = get_current_scope();
                                printf("\tLOADI(%d);\n", $3->int_val); 
                                set_symbol_value(string_to_sid($3->name), $3);
                                }
| ID                           {
                                $1->type_val = $<att>0->type_val;
                                $1->offset = get_offset(); 
                                $1->scope = get_current_scope();
                                $$ = $1;
                                printf("\tLOADI(%d);\n", $1->int_val); 
                                set_symbol_value(string_to_sid($1->name), $1);
                                }
;

vir : VIR                      {}
;

fun_body : AO block AF         {if (strcmp($<att>0->name, "main")) {
                                    if (!strcmp($<att>0->type_return, "void") && is_return_seen())
                                        compiler_error("Function %s is void but has a return statement.\n", $<att>0->name);
                                        if (strcmp($<att>0->type_return, "void") && !is_return_seen())
                                        compiler_error("Function %s has a return type but hasn't got a return statement.\n", $<att>0->name);
                                    printf("}\n\n");
                                }
                                else {
                                    //printf("\tSTORE(mp);\n"); 
                                    //printf("\tEXIT_MAIN;\n");
                                    printf("FinMain:\n\tNOP;\n");
                                    printf("\n\tprint_stack();\n\n");
                                    printf("}\n");
                                }
                                reset_return_flag();}
;

// Block
block:
decl_list inst_list            {}
;

// I. Declarations

decl_list : decl_list decl     {}
|                              {}
;

decl: var_decl PV              {}
;

var_decl : type vlist          {}
;

type
: typename                     {$$ = $1;}
;

typename
: TINT                          {$$ = new_attribute(); $$->name = "int"; $$->type_val = INT;}
| VOID                          {$$ = new_attribute(); $$->name = "void"; $$->type_val = VOID;}
;

// II. Intructions

inst_list: inst inst_list   {}
| inst                      {}
;

pv : PV                       {}
;
 
inst:
exp pv                        {}
| ao block af                 {}
| aff pv                      {}
| ret pv                      {}
| cond                        {}
| loop                        {}
| pv                          {}
;

// Accolades pour gerer l'entrée et la sortie d'un sous-bloc

ao : AO                         {
                                reset_return_flag();
                                enter_block(); 
                                printf("\tENTER_BLOCK(0);\n");
                                }
;

af : AF                         {
                                exit_block(); 
                                if(is_return_seen()) printf("\tEXIT_BLOCK(0);\n");
                                else printf("\tEXIT_BLOCK_NO_RETURN(0);\n");
                                reset_return_flag();
                                }
;


// II.1 Affectations

aff : ID EQ exp               {
                                attribute x;
                                sid s = string_to_sid($1->name);
                                sid exp_sid = string_to_sid($3->name);
                                attribute exp;
                                if (sid_valid(exp_sid) && (exp = get_symbol_value(exp_sid))->is_func && !strcmp(exp->type_return, "void"))
                                    compiler_error("Can't assign return value of a void function %s since it doesn't has one.\n", get_symbol_value(exp_sid)->name);
                                if (sid_valid(s)) {
                                  x = get_symbol_value(s);
                                  char* str = "mp";
                                  for (unsigned int i = 0; i < get_current_scope() - x->scope; i++)
                                      asprintf(&str, "stack[%s - 1]", str);
                                  if (x->is_in_func)
                                    printf("\tSTORE(mp - 1 - %d)\n\n\tprint_stack();\n\n", x->args_rank);                                        
                                  else
                                    printf("\tSTORE(%s + %d);\n\n\tprint_stack();\n\n", str, x->offset);
                                } else {
                                    compiler_error("Can't assign value %d to %s. Attribute hasn't been declared.\n", $3->int_val, $1->name);
                                }
                              }
;


// II.2 Return
ret : RETURN exp              {return_seen(); if (exists_symbol_value(string_to_sid("main"))) printf("\tSTORE(mp);\n\tEXIT_MAIN;\n\tGOTO(FinMain);\n"); else printf("\treturn;\n");}
| RETURN PO PF                {return_seen(); printf("\ttSTORE(mp);\n\tEXIT_MAIN;\n\tGOTO(FinMain);\n");}
;

// II.3. Conditionelles
//           N.B. ces rêgles génèrent un conflit déclage reduction
//           qui est résolu comme on le souhaite par un décalage (shift)
//           avec ELSE en entrée (voir y.output)

cond :
if bool_cond inst elsop       {}
;

// la regle avec else vient avant celle avec vide pour induire une resolution
// adequate du conflit shift / reduce avec ELSE en entrée

elsop : else inst             {printf("Fin%d:\n\tNOP;\n", $<att>-2->label_number);}
|                             {printf("Else%d:\n\tNOP;\n", $<att>-2->label_number);}
;

bool_cond : PO exp PF         {
                                $$ = new_attribute();
                                $$->label_number = $<att>0->label_number;
                                printf("\n\tprint_stack();\n\n");
                                printf("\tIFN(Else%d);\n", $<att>0->label_number);
                              }
;

if : IF                       {$$ = new_attribute();
                                $$->label_number = new_label();}
;

else : ELSE                   {
                                $$ = new_attribute();
                                $$->label_number = $<att>-2->label_number;
                                printf("\n\tprint_stack();\n\n\tGOTO(Fin%d);\nElse%d:\n", $$->label_number, $<att>-2->label_number);}
;

// II.4. Iterations

loop : while while_cond inst  {printf("\n\tprint_stack();\n\n\tGOTO(Loop%d);\nEnd%d:\n\tNOP;\n", $1->label_number, $2->label_number);}
;

while_cond : PO exp PF        {
                                $$ = new_attribute();
                                $$->label_number = $<att>0->label_number;
                                printf("\n\tprint_stack();\n\n");
                                printf("\tIFN(End%d);\n", $$->label_number);}

while : WHILE                 {
                                $$ = new_attribute();
                                $$->label_number = new_label();
                                printf("Loop%d:\n", $$->label_number);}
;


// II.3 Expressions
exp:
// II.3.1 Exp. arithmetiques
 MOINS exp %prec UNA         {printf("\tNEGI;\n\tprint_stack();\n\n\n");}
         // -x + y lue comme (- x) + y  et pas - (x + y)
| exp PLUS exp                {printf("\tADDI;\n\tprint_stack();\n\n\n");}
| exp MOINS exp               {printf("\tSUBI;\n\tprint_stack();\n\n\n");}
| exp STAR exp                {printf("\tMULTI;\n\tprint_stack();\n\n\n");}
| exp DIV exp                 {printf("\tDIVI;\n\tprint_stack();\n\n\n");}
| PO exp PF                   {$$=$2;}
| ID                          {
                                sid s = string_to_sid($1->name);
                                if (!exists_symbol_value(s)) 
                                        compiler_error("Attribute %s hasn't been declared in this scope.\n", $1->name);
                                attribute x = get_symbol_value(s);
                                char* str = "mp";
                                for (unsigned int i = 0; i < get_current_scope() - x->scope; i++)
                                    asprintf(&str, "stack[%s - 1]", str);
                                if (x->is_in_func)
                                    printf("\tLOAD(mp - 1 - %d)\n", x->args_rank);
                                else 
                                    printf("\tLOAD(%s + %d);\n", str, x->offset);
                              }
| app                         {$$=$1;}
| NUM                         {printf("\tLOADI(%d);\n", $1->int_val);}


// II.3.2. Booléens

| NOT exp %prec UNA           {printf("\tNT;\n");}
| exp INF exp                 {printf("\tLT;\n");}
| exp SUP exp                 {printf("\tGT;\n");}
| exp INFEQ exp               {printf("\tLEQ;\n");}
| exp SUPEQ exp               {printf("\tGEQ;\n");}
| exp EQUAL exp               {printf("\tEQL;\n");}
| exp DIFF exp                {printf("\tNEQ;\n");}
| exp AND exp                 {printf("\tANDI;\n");}
| exp OR exp                  {printf("\tORI;\n");}

;

// II.4 Applications de fonctions

app : ID PO args PF           {
                                if (!exists_symbol_value(string_to_sid($1->name)))
                                    compiler_error("Unknown function %s.\n", $1->name);
                                attribute x = get_symbol_value(string_to_sid($1->name));
                                if ($<att>3->args_number < x->args_number)
                                    compiler_error("Not enough arguments for function %s. Expected %d, got %d.\n", $1->name, x->args_number, $<att>3->args_number);
                                if ($<att>3->args_number > x->args_number)
                                    compiler_error("Too many arguments for function %s. Expected %d, got %d\n", $1->name, x->args_number, $<att>3->args_number);
                                printf("\tENTER_BLOCK(%d);\n", x->args_number);
                                printf("\t%s_pcode();\n", $1->name);
                                if (strcmp(x->type_return, "void")) {
                                    printf("\n\tprint_stack();\n\n");
                                    printf("\tEXIT_BLOCK(%d);\n", x->args_number);
                                } else {
                                    printf("\n\tprint_stack();\n\n");
                                    printf("\tEXIT_BLOCK_NO_RETURN(%d);\n", x->args_number);
                                }
                                }

;

args :  arglist               {}
|                             {$$ = new_attribute(); $$->args_number = 0;}
;

arglist : exp VIR arglist     { $$->args_number++;
                                $<att>-1->args_number = $$->args_number;}
| exp                         { $<att>-1->args_number = 1; $$ = $<att>-1;}
;



%% 
int main () {

  /* Ici on peut ouvrir le fichier source, avec les messages 
     d'erreur usuel si besoin, et rediriger l'entrée standard 
     sur ce fichier pour lancer dessus la compilation.
   */

printf("#include \"PCode.h\"\n#include <stdio.h>\n\n");

//freopen("test.myc", "r", stdin);
return yyparse ();
 
} 