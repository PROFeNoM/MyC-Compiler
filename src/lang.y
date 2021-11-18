%{

#include "Table_des_symboles.h"
#include "Attribute.h"
#include "PCode/PCode.h"

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

vlist: vlist vir ID            {$3->offset = get_offset();printf("LOADI(%d);\n", $3->int_val); set_symbol_value(string_to_sid($3->name), $3);}
| ID                           {$1->offset = get_offset();printf("LOADI(%d);\n", $1->int_val); set_symbol_value(string_to_sid($1->name), $1);}
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

ao : AO                       {}
;

af : AF                       {}
;


// II.1 Affectations

aff : ID EQ exp               {printf("STORE(mp + %d);\n", get_symbol_value($1->name)->offset);}
;


// II.2 Return
ret : RETURN exp              {if (exists_symbol_value($2->name)) printf("STORE(mp);\n"); printf("EXIT_MAIN;\n");}
| RETURN PO PF                {printf("EXIT_MAIN;\n");}
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

elsop : else inst             {}
|                             {}
;

bool_cond : PO exp PF         {}
;

if : IF                       {}
;

else : ELSE                   {}
;

// II.4. Iterations

loop : while while_cond inst  {}
;

while_cond : PO exp PF        {}

while : WHILE                 {}
;


// II.3 Expressions
exp
// II.3.1 Exp. arithmetiques
: MOINS exp %prec UNA         {printf("NEGI;\n");}
         // -x + y lue comme (- x) + y  et pas - (x + y)
| exp PLUS exp                {printf("ADDI;\n");}
| exp MOINS exp               {printf("SUBI;\n");}
| exp STAR exp                {printf("MULTI;\n");}
| exp DIV exp                 {printf("DIVI\n");}
| PO exp PF                   {}
| ID                          {printf("LOAD(mp + %d);\n", get_symbol_value($1->name)->offset);}
| app                         {}
| NUM                         {printf("LOADI(%d);\n", $1->int_val);}


// II.3.2. Booléens

| NOT exp %prec UNA           {}
| exp INF exp                 {printf("LT;\n");}
| exp SUP exp                 {printf("GT;\n");}
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
return yyparse ();
 
} 

