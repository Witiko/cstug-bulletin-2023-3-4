.PHONY: all clear FORCE

DOCKER = docker run --rm -u $(shell id -u):$(shell id -g) --env TEXMFVAR=/var/tmp/texmf-var -v "$$PWD":/workdir -w /workdir
IMAGE = texlive/texlive:TL2023-historic-with-cache

all: FORCE
	$(DOCKER) $(IMAGE) ./run.sh
	touch $(basename $@).info
	! grep -F '\csbul@webtrue' literate.info || $(DOCKER) $(IMAGE) pdfannotextractor literate.pdf
	! grep -F '\csbul@webtrue' rezani.info || $(DOCKER) $(IMAGE) pdfannotextractor rezani.pdf

clear:
	true
