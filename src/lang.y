%{

#include "Table_des_symboles.h"
#include "Attribute.h"
#include "PCode/PCode.h"

#define _GNU_SOURCE
#include <stdio.h>
  
extern int yylex();
extern int yyparse();

void yyerror (char* s) {
  printf ("%s\n",s);
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

%token <att> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR

%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DIFF EQUAL SUP INF       // higher priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
%nonassoc ELSE


%start prog  

// liste de tous les non terminaux dont vous voulez manipuler l'attribut
%type <att> exp  typename  type  vlist
         

%%

prog : func_list               {}
;

func_list : func_list fun      {}
| fun                          {}
;


// I. Functions

fun : fun_type fun_head fun_body        {}
;

fun_type: type                 {printf("%s ", $1->name);}

fun_head : ID PO PF            {printf("%s() {\n", $1->name);} // erreur si profondeur diff zero
| ID PO params PF              {}
;

params: type ID vir params     {}
| type ID                      {}

vlist: vlist vir ID            {
                                $3->offset = get_offset(); 
                                $3->scope = get_current_scope();
                                printf("\tLOADI(%d);\n", $3->int_val); 
                                set_symbol_value(string_to_sid($3->name), $3);
                                }
| ID                           {
                                $1->offset = get_offset(); 
                                $1->scope = get_current_scope();
                                printf("\tLOADI(%d);\n", $1->int_val); 
                                set_symbol_value(string_to_sid($1->name), $1);
                                }
;

vir : VIR                      {}
;

fun_body : AO block AF         {printf("}\n");}
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

ao : AO                       {enter_block(); printf("\tENTER_BLOCK(0);\n");}
;

af : AF                       {exit_block(); printf("\tEXIT_BLOCK(0);\n");}
;


// II.1 Affectations

aff : ID EQ exp               {
                                attribute x;
                                sid s = string_to_sid($1->name);
                                if (sid_valid(s)) {
                                  x = get_symbol_value(s);
                                  char* str = "mp";
                                  //print_st();
                                  for (unsigned int i = 0; i < get_current_scope() - x->scope; i++)
                                      asprintf(&str, "stack[%s - 1]", str);
                                  printf("\tSTORE(%s + %d);\n", str, x->offset);
                                } else {
                                    compiler_error("Can't assign value. Attribute hasn't been declared in this scope.\n");
                                }
                              }
;


// II.2 Return
ret : RETURN exp              {if (sid_valid(string_to_sid($2->name))) printf("\tSTORE(mp);\n"); printf("\tEXIT_MAIN;\n");}
| RETURN PO PF                {printf("\tEXIT_MAIN;\n");}
;

// II.3. Conditionelles
//           N.B. ces rêgles génèrent un conflit déclage reduction
//           qui est résolu comme on le souhaite par un décalage (shift)
//           avec ELSE en entrée (voir y.output)

cond :
if bool_cond inst elsop       {printf("Fin:\n\tNOP;\n");}
;

// la regle avec else vient avant celle avec vide pour induire une resolution
// adequate du conflit shift / reduce avec ELSE en entrée

elsop : else inst             {}
|                             {}
;

bool_cond : PO exp PF         {printf("\tIFN(Else);\n");}
;

if : IF                       {}
;

else : ELSE                   {printf("\tGOTO(Fin);\nElse:\n");}
;

// II.4. Iterations

loop : while while_cond inst  {printf("\tGOTO(Loop);\nEnd:\n");}
;

while_cond : PO exp PF        {printf("\tIFN(END);\n");}

while : WHILE                 {printf("Loop:\n");}
;


// II.3 Expressions
exp
// II.3.1 Exp. arithmetiques
: MOINS exp %prec UNA         {printf("\tNEGI;\n");}
         // -x + y lue comme (- x) + y  et pas - (x + y)
| exp PLUS exp                {printf("\tADDI;\n");}
| exp MOINS exp               {printf("\tSUBI;\n");}
| exp STAR exp                {printf("\tMULTI;\n");}
| exp DIV exp                 {printf("\tDIVI\n");}
| PO exp PF                   {}
| ID                          {
                                sid s = string_to_sid($1->name);
                                if (!exists_symbol_value(s)) compiler_error("Attribute hasn't been declared in this scope.\n");
                                attribute x = get_symbol_value(s);
                                char* str = "mp";
                                for (unsigned int i = 0; i < get_current_scope() - x->scope; i++)
                                    asprintf(&str, "stack[%s - 1]", str);
                                printf("\tLOAD(%s + %d);\n", str, x->offset);
                              }
| app                         {}
| NUM                         {printf("\tLOADI(%d);\n", $1->int_val);}


// II.3.2. Booléens

| NOT exp %prec UNA           {}
| exp INF exp                 {printf("\tLT;\n");}
| exp SUP exp                 {printf("\tGT;\n");}
| exp EQUAL exp               {}
| exp DIFF exp                {}
| exp AND exp                 {}
| exp OR exp                  {}

;

// II.4 Applications de fonctions

app : ID PO args PF           {}
;

args :  arglist               {}
|                             {}
;

arglist : exp VIR arglist     {}
| exp                         {}
;



%% 
int main () {

  /* Ici on peut ouvrir le fichier source, avec les messages 
     d'erreur usuel si besoin, et rediriger l'entrée standard 
     sur ce fichier pour lancer dessus la compilation.
   */

printf ("Compiling MyC source code into PCode (Version 2021) !\n\n");

//freopen("test.myc", "r", stdin);
return yyparse ();
 
} 

