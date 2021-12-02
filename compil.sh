#!/bin/bash

RED=`tput setaf 1`
GREEN=`tput setaf 2`
NC=`tput sgr0`

if [ ! -x ./myc ]; then
    make
fi

FULL_PATH=$1
FILENAME=$(basename -- "$FULL_PATH")
F="${FILENAME%.*}"
ERROR_FILE_PATTERN="ERROR_.*"

echo -e "\n${GREEN}%%%%%%% START $FILENAME COMPILATION %%%%%%%${NC}"

./myc< $FULL_PATH > ./test/$F.c
echo "C file created at ./test/$F.c";
# shellcheck disable=SC2074
if [[ "$F" =~ $ERROR_FILE_PATTERN ]]; then
  echo "${RED}Executable aren't created for ERROR files. Error should be displayed right above ^^^^.${NC}"
else
  gcc -o ./test/$F ./test/$F.c ./src/PCode/PCode.o -Isrc/PCode/
  echo "Executable created at ./test/$F";
fi

echo -e "${GREEN}%%%%%%% END $FILENAME COMPILATION %%%%%%%${NC}\n"