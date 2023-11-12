#!/bin/bash
set -ex
cd ukazky
pdfcsplain zdrojaky
pdfcsplain ukazky
cd ..
mpost graf
mptopdf graf
pdflatex -interaction=nonstopmode literate || true
pdflatex literate
pdflatex literate
pdflatex rezani
pdflatex rezani
