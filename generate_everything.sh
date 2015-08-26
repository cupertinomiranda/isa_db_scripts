#!/bin/bash

erb templates/opc.c.erb > "$1/include/opcode/arc-func.h"
erb templates/reloc.def.erb > "$1/include/elf/arc-reloc.def"
ruby patch_reloc.c.rb $1/bfd/reloc.c
indent -nbad -bap -nbc -bbo -bl -bli2 -bls -ncdb -nce -cp1 -cs -di2 -ndj -nfc1 -nfca -hnl -i2 -ip5 -lp -pcs -psl -nsc -nsob "$1/include/opcode/arc-func.h" 
