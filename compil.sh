make
FULL_PATH=$1
FILENAME=$(basename -- "$FULL_PATH")
F="${FILENAME%.*}"
./lang < $FULL_PATH > ./test/$F.c
gcc -o ./test/$F ./test/$F.c ./src/PCode/PCode.o -Isrc/PCode/