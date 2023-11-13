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
pdflatex literate
pdflatex literate
pdflatex rezani
pdflatex rezani
