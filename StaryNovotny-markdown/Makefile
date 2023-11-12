.PHONY: all preview clear FORCE

DOCKER = docker run --rm -u $(shell id -u):$(shell id -g) --env TEXMFVAR=/var/tmp/texmf-var -v "$$PWD":/workdir -w /workdir
IMAGE = texlive/texlive:TL2022-historic-with-cache
LATEXMK = latexmk -lualatex -shell-escape -f
DOCUMENT = main.tex

all: $(basename $(DOCUMENT)).pdf

preview: $(DOCUMENT)
	$(DOCKER) $(IMAGE) $(LATEXMK) -pvc $<

clear: $(DOCUMENT)
	$(DOCKER) $(IMAGE) $(LATEXMK) -C $<

%.pdf: %.tex FORCE
	rm -f $(basename $@).bbl $(basename $@).pax
	$(DOCKER) $(IMAGE) $(LATEXMK) $<
	touch $(basename $@).info
	! grep -F '\csbul@webtrue' $(basename $@).info || $(DOCKER) $(IMAGE) pdfannotextractor $@
