# Résumé

Le projet de compilation a pour but la réalisation d'un compilateur d'un mini langage appelé pour l'occasion myC vers du PCode. Le langage source proposé, un mini langage C, devra donc être compilé en PCode C.

Il a été réalisé par Alexandre Choura et Radouane Ouriha, élèves à l'Enseirb-Matmeca en deuxième année informatique. (Team 23)

# Dossiers et contenu

Le projet s'organise de la sorte :
  - `src/` : Sources du compilateur
  - `tst/` : Ensemble de fichiers sources et les résultats de leurs compilations, permettant de tester les différents aspects des fonctionnalités du projet. Pour tous, la valeur de retour du main se situe à `stack[mp]`
    * Il est à noter que certains fichiers **doivent provoquer des erreurs de compilation** (et n'ont donc pas d'executable associé), permettant de vérifier les messages d'erreurs associés
    * De plus, les executables ont déjà des print_stack() intégrés dans le PCode C généré.
    * `pcode-ex[1-7].myc` : Fichier d'exemples proposés pour le projet
    * `hanoi_tower.myc` : La valeur de retour doit être 15 (Expressions arithmétiques, conditionnelle, blocs et fonction récursive).
    * `if_elseif_else.myc` : La valeur de retour doit être -1 (Déclarations, affectations, réutilisation, conditionnelles)
    * `max.myc`  : La valeur de retour doit être 1 (Déclarations, affectations, réutilisations, conditionnelles, blocs, fonctions)
    * `multiple_if.myc` : La valeur de retour doit être 13 (Expressions arithmétiques, déclarations, affectations, réutilisations, conditionnelles imbriquées) 
    * `negative_precedence.myc` : La valeur de retour doit être 0 (Expressions arithmétiques, précédence de la négation, blocs, fonctions)
    * `nested_while_if_with_function[1-2].myc` : Les valeurs de retour doivent être 5 et 9 (Expressions arithmétiques, déclarations, affectations, réutilisations, conditionnelles, itérateur, blocs, fonction)
    * `pow.myc` : La valeur de retour doit être 8 (Expressions arithmétiques, conditionnelles, blocs, fonction récursive)
    * `sumTo.myc` : La valeur de retour doit être 5050 (Expressions arithmétiques, déclarations, affectations, réutilisations, itérateur, blocs, fonction)
    * `ERROR_.*.myc` : Doivent provoquer une **erreur de compilation** (message qui est donc provoqué à la compilation, bien-sûr...)
  - `Makefile` : Compile le compilateur en un executable `myc` se trouvant dans le repertoire courant
  - `compil.sh` : Script shell permettant de générer le compilateur s'il n'existe pas et compiler le fichier `.myc` donné en argument en `.c` et son executable, qui se trouveront alors dans le répertoire `test/`
  - `README.md` : Indique en *quelques* lignes l'étendu du compilateur réalisé

# Compilation et exécution

Afin de pouvoir compiler notre programme et l'utiliser, plusieurs règles du `Makefile` peuvent être utiles :
  - `make clean` : Supprime tous les fichiers produits durant la compilation ou les tests
  - `make` : Compile les sources permettant de créer le compilateur `myc`
  - `make test` : Compile les fichiers sources `./test/*.myc`, générant un fichier `.c` et son exécutable dans le répertoire `test/`.

# Travail effectué

Nous avons réussi à effectuer toutes les fonctionnalités du projet:
  - un calcul d'expressions arithmétiques arbitraires **FONCTIONNEL**
  - des déclarations, affectations et réutilisations de variables entières **FONCTIONNEL**
  - des conditionelles (if, et if-else) **FONCTIONNEL**
  - un itérateur (while) **FONCTIONNEL**
  - un mecanisme de sous-blocs avec déclarations locales et les problèmes de visibilités et de masquages associés **FONCTIONNEL**
  - des fonctions à la C avec paramètres entiers et vérification de type associé (nb arguments) **FONCTIONNEL**
  - un traitement des fonctions récursives **FONCTIONNEL**


