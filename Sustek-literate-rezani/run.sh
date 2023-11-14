#!/bin/bash
set -ex
cd ukazky
pdfcsplain zdrojaky
pdfcsplain ukazky
cp ukazky.pdf ukazky-sede.pdf
../../pdf-to-grayscale.sh ukazky-sede.pdf
cd ..
mpost graf
mptopdf graf
pdflatex -interaction=nonstopmode literate || true
latexmk -pdflatex -f literate
latexmk -pdflatex -f rezani
