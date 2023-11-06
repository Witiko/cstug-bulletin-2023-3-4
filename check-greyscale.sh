#!/bin/sh
# Check that the $@ PDFs only use black ink.
[ `for INPUT; do
     gs -o - -sDEVICE=inkcov "$INPUT" | grep '^ ' |
       grep -nvx ' 0\.00000  0\.00000  0\.00000 .* CMYK OK' |
       sed s+^+"$INPUT, page "+ | tee /dev/stderr
   done | wc -l` = 0 ]
