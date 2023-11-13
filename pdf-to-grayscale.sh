#!/bin/sh
# Convert PDFs $@ into grayscale PDFs.
set -e
TEMP=`mktemp`; trap 'rm $TEMP' EXIT
for INPUT; do
  gs -sOutputFile=$TEMP -sDEVICE=pdfwrite \
     -dColorConversionStrategy=/Gray \
     -dProcessColorModel=/DeviceGray -dCompatibilityLevel=1.3 \
     -dNOPAUSE -dBATCH "$INPUT"
  cp $TEMP "$INPUT"
done
