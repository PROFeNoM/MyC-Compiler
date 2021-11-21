/*
 *  PCode.h
 * 
 *  Created by Janin on 12/11/21.
 *  Copyright 2021 ENSEIRB. All rights reserved.
 *
 *  La pile de PCode est codée comme un tableau C.
 *  Les "adresses" de PCode sont alors codées comme des indices
 *  dans ce tableau. Autrement dit, on évite, pour la beauté du geste,
 *  d'utiliser explicitement les pointeurs C.
 *  Bien sur stack[k] c'est la même chose que *(stack+k)...
 */


#ifndef PCODE_H
#define PCODE_H

#define SIZE 100


extern int stack[SIZE];

extern int sp;
     // Stack pointeur (ou index) qui pointe toujours sur la première
     // case LIBRE.
     // On empile en incrémentant sp
     // On dépile en le décrémentant

extern int mp;
     // Mark pointeur : un pointeur (ou index) qui marque une position fixe,
     // sur la pile, à partir de laquelle on peut retrouver les données
     // (paramètres, variables locales) propres au bloc courant.


/*************************************************/
// Instructions P-CODE, définit comme des macros C

/********** Empiler / depiler un entier ***************/

// empiler
#define LOADI(X)  stack[sp ++] = X;

#define LOAD(P)   stack[sp ++] = stack[P];
  // post-incrémentation !! sp pointe sur la première case vide

// depiler 
#define STORE(P)  stack[P] = stack[-- sp];
  // pre-décrémentation !! sp pointe sur la première case vide


/*********** Opérations arithmetiques entières binaires *********/

/* On dépile, on effectue le calcul
   on rempile le résultat.

   On peut ajouter des fonctions binaires de PCode si besoin.
   Ex : ==
*/

#define ADDI stack[sp - 2] = stack[sp - 2] + stack[sp - 1]; sp--

#define MULTI stack[sp - 2] = stack[sp - 2] * stack[sp - 1]; sp--

#define SUBI stack[sp - 2] = stack[sp - 2] - stack[sp - 1]; sp--

// Comparaisons

#define LT stack[sp - 2] = stack[sp - 2] < stack[sp - 1]; sp--

#define GT stack[sp - 2] = stack[sp - 2] > stack[sp - 1]; sp--

#define LEQ stack[sp - 2] = stack[sp - 2] <= stack[sp - 1]; sp--

#define GEQ stack[sp - 2] = stack[sp - 2] >= stack[sp - 1]; sp--

/*************************** Branchements ******************/
// La condition est en sommet de pile et elle est dépilée après le test

      // test condition positive
#define IFT(L) if (stack[--sp]) goto L

      // test negation de la condition
#define IFN(L) if (!(stack[--sp])) goto L

      // branchement inconditionel
#define GOTO(L) goto L

/*****************  NOP ************************************/

#define NOP 

/*********** Gestion des sous-blocks avec la pile. *********/

  /* Pour les blocs imbriqués, on doit, gerer la sauvegarde et la restoration
     du mp et du sp, et les déclarations de variables locales.

     Pourles blocs de fonctions, on doit aussi gere le passage
     et l'accès aux arguements de cette fonction */


  /*
     L'objectif de ENTER_BLOCK(N) et EXIT_BLOCK(N) est d'atteindre 
     l'invariant suivant:
     (1) dans le bloc courant, la nième variable du bloc courant est 
     à l'index :
              mp+n 
     avec l'index mp+0 reservée à la valeur de retour du bloc

     (2) dans le bloc courant, la nième variable bloc englobant est
     à l'index : 
            stack[mp-1] + n
     
     Nota : le  mp du bloc englobant est (toujours) stocké à l'index (mp-1).
     Si mp-1 est négatif, c'est qu'on est dans le bloc du main !!!

     (3) dans le bloc courant, la nième variable du bloc englobant le 
     bloc englobant est à l'index :
            stack[stack[mp - 1] - 1] + n

     etc...

  */



// restore le sommet de pile (uniquement pour la fin de la fonction main)
#define EXIT_MAIN sp = mp+1

// sauvegarde le mark pointeur et en définit un nouveau
#define ENTER_BLOCK(N) stack[sp++] = mp; mp = sp
   // ancien mp sauvegardé à l'adresse mp-1
   // les arguements d'un appel de fonction auront été empilé
   // avant l'appel a ENTER_BLOC

/* EXIT_BLOC(N) effectue, dans l'ordre:
    - restoration du mp,
    - copie de la valeur de retour à l'emplacement approprié 
      (sommet de pile de l'appelant). Cette valeur de retour 
      doit se trouver à l'index mp de l'appelé,
    - restoration du sp de l'appelant,
    avec N qui représente le nombre d'arguements (entier !!!) de la fonction.
    Mettre N = 0 pour un bloc simple.
*/

#define EXIT_BLOCK(N) mp = stack[mp-1];stack[sp-N-2]=stack[sp-1];sp-= N+1

/*

     (4) dans le cas d'un appel de fonction à N arguments, on prendra soin 
     de charger les arguments de la fonction sur la pile (dans l'ordre 
     de gauche à droite) avant de faire appel à ENTER_BLOCK(N).

     L'appel d'une fonction f se fait alors en appelant une fonction 
     (qu'on a produit) pcode_f sans arguement.

     Dès lors, le kième argument de la fonction est lu (par l'appelé) 
     dans la pile à l'adresse
              mp - 1 - (N + k -1) 
     Voir les exemples 6 et 7 avec:
        - pcode-ex6.c appel simple à deux arguements
        - pcode-ex7.c appel récursif à un arguement.
*/


/***************************************************/
/* Autres fonctions pour le debug */

int empty_stack ();

int full_stack ();

int valid_stack ();

void print_stack();


#endif

