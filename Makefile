SHELL=/bin/bash

.PHONY: all test test-preprint test-xml FORCE

all: bul.pdf bul-obalka.pdf bul-engtoc.pdf bul-toc.pdf bul-blok.pdf bul-web.pdf \
	bul-obalka-margins-0.pdf bul-blok-margins-0.pdf \
	bul-obalka-margins-10.pdf bul-blok-margins-10.pdf \
	bul-obalka-margins-20.pdf bul-blok-margins-20.pdf \
	bul-obalka-margins-30.pdf bul-blok-margins-30.pdf \
	bul-obalka-margins-40.pdf bul-blok-margins-40.pdf

DOCKER = docker
DOCKER_RUN = $(DOCKER) run --rm -u $(shell id -u):$(shell id -g) --env TEXMFVAR=/var/tmp/texmf-var -v "$$PWD":/workdir -w /workdir
PDFLATEX_2020 = $(DOCKER_RUN) texlive/texlive:TL2020-historic-with-cache pdflatex
PDFLATEX_2023 = $(DOCKER_RUN) texlive/texlive:TL2023-historic-with-cache pdflatex
LATEXMK = $(DOCKER_RUN) texlive/texlive:TL2020-historic-with-cache latexmk
PDFTK = $(DOCKER_RUN) mnuessler/pdftk
PARALLEL = parallel --joblog joblog --halt now,fail=1 --jobs 0 --

FONTS = matha8.pfb matha9.pfb matha10.pfb mathb10.pfb

math%.pfb:
	$(DOCKER_RUN) texlive/texlive:TL2020-historic-with-cache t1disasm $(shell $(DOCKER_RUN) texlive/texlive:TL2020-historic-with-cache kpsewhich $@) | sed -e 's!%$$!!' > $@
	$(DOCKER_RUN) texlive/texlive:TL2020-historic-with-cache t1asm -b $@ | sponge $@

define clear-and-typeset
$(PARALLEL) 'make -C {} clear all' ::: */
$(PDFLATEX_2020) $<
endef

define typeset
$(PARALLEL) 'make -C {} all' ::: */
$(PDFLATEX_2020) $<
endef

images: FORCE
	$(DOCKER) build . -f Dockerfile.TL2020 -t texlive/texlive:TL2020-historic-with-cache
	$(DOCKER) build . -f Dockerfile.TL2022 -t texlive/texlive:TL2022-historic-with-cache
	$(DOCKER) build . -f Dockerfile.TL2023 -t texlive/texlive:TL2023-historic-with-cache

bul.pdf: bul.tex $(FONTS) FORCE
	$(LATEXMK) -c $<
	$(clear-and-typeset)
	$(typeset)
	$(typeset)

bul-web.pdf: bul-web.tex bul.tex $(FONTS) FORCE
	$(LATEXMK) -c $<
	$(clear-and-typeset)
	$(typeset)
	$(typeset)

bul-engtoc.pdf: bul.pdf
	$(PDFTK) $< cat end output $@

bul-toc.pdf: bul.pdf
	$(PDFTK) $< cat 2 output $@

bul-obalka.pdf: bul.pdf
	$(PDFTK) $< cat 1 2 r2 r1 output $@

bul-blok.pdf: bul.pdf
	$(PDFTK) $< cat 3-r3 output $@

bul-margins-%.pdf: bul.pdf
	$(PDFLATEX_2023) '\def\offset{$(patsubst bul-margins-%.pdf, %, $@)}\input bul-margins.tex'
	mv bul-margins.pdf $@

bul-obalka-margins-%.pdf: bul.pdf bul-margins-%.pdf
	$(PDFTK) A=$< B=$(word 2,$^) cat A1 B1 Br2 Br1 output $@

bul-blok-margins-%.pdf: bul-margins-%.pdf
	$(PDFTK) $< cat 2-r2 output $@

PAGETOTAL = $$(( 2 + 3 + 36 + 9 + 14 + 14 + 14 + 12 ))
COLORPAGES = 20

test:
	(( $$(pdfinfo bul.pdf     | grep 'Pages:' | awk '{print $$2}') == $(PAGETOTAL) + 4))
	(( $$(pdfinfo bul-web.pdf | grep 'Pages:' | awk '{print $$2}') == $(PAGETOTAL) + 4))
	# ! grep '[^:]*:.*[ÁáČčĎďÉéĚěÍíĽľĹĺÓóŘřŠšŤťÚúŮůÝýŽž]'   <(pdf2txt bul-engtoc.pdf)  # Ensure no Czechoslovak letters in English table of contents
	! grep -E '^\s*([^:]*):\s*\1:' <(pdf2txt bul-toc.pdf) <(pdf2txt bul-engtoc.pdf)  # Ensure no repeated names in table of contents
	(( $$(./check-greyscale.sh bul.pdf |& wc -l) == $(COLORPAGES) + 1))

test-xml:
	xmllint --xinclude --noout --relaxng bulletin.rng bulletin.xml
	! grep '[\\~{}]' bulletin.xml */article.xml */citations.xml  # Ensure no TeX-like characters
	! grep -F '<citation/>' */article.xml */citations.xml  # Ensure no empty citations

test-preprint:
	(( $$(pdfinfo bul-obalka-coated_fogra39.pdf | grep 'Pages:' | awk '{print $$2}') == 4))
	(( $$(pdfinfo bul-blok-uncoated_fogra29.pdf | grep 'Pages:' | awk '{print $$2}') == $(PAGETOTAL)))
	(( $$(./check-greyscale.sh bul-blok-uncoated_fogra29.pdf |& wc -l) == $(COLORPAGES)))
