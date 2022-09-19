BUILD = build
BOOKNAME = CICD_for_Monorepos
TITLE = title.txt
CHAPTERS = chapters/01-introduction.md \
		   chapters/02-what-is-monorepo.md \
		   chapters/03-continuous-integration.md \
		   chapters/04-continuous-integration-demo.md \
		   chapters/05-continuous-delivery.md \
		   chapters/06-final-words.md

# handle non-intel archs
EXTRA_OPTS =
ARCH = $(shell arch)
ifeq ($(ARCH),arm64)
	EXTRA_OPTS += --platform linux/amd64
endif

all: book 
book: pdf #ebook
docx: $(BUILD)/docx/$(BOOKNAME).docx
pdf: $(BUILD)/pdf/$(BOOKNAME).pdf
more: $(BUILD)/pdf/more.pdf

clean:
	rm -r $(BUILD)


$(BUILD)/docx/$(BOOKNAME).docx: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/docx
	docker run --rm $(EXTRA_OPTS) --volume `pwd`:/data pandoc/latex:2.6 -f markdown-implicit_figures -H make-code-small.tex -V geometry:margin=1.5in -o /data/$@ $^

$(BUILD)/pdf/$(BOOKNAME).pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/pdf
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/latex:2.6 \
		-f markdown-implicit_figures \
		-H make-code-small.tex \
		-V geometry:margin=1.5in \
		-o /data/$@ $^

$(BUILD)/pdf/more.pdf: chapters/07-wait-there-is-more.md
	mkdir -p $(BUILD)/pdf
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/latex:2.6 \
		-f markdown-implicit_figures \
		-H make-code-small.tex \
		-V geometry:margin=1.5in \
		-o /data/$@ $^

# intermediate format for epub, uses small figures
$(BUILD)/html/$(BOOKNAME).html: title.txt $(CHAPTERS_EBOOK)
	mkdir -p $(BUILD)/html $(BUILD)/html/figures
	cp figures/* $(BUILD)/html/figures
	cp figures-ebook/* $(BUILD)/html/figures
	docker run --rm $(EXTRA_OPTS) --volume `pwd`:/data pandoc/crossref:2.10 -o /data/$@ $^
 
# kindle-optimized epub
# note: output-profile=tablet converts best to kindle
$(BUILD)/epub/$(BOOKNAME).epub: $(BUILD)/html/$(BOOKNAME).html
	mkdir -p $(BUILD)/epub
	docker run --rm $(EXTRA_OPTS) --volume `pwd`:/data --entrypoint ebook-convert -w /data linuxserver/calibre $^ /data/$@ \
		--output-profile tablet \
		--chapter "//*[name()='h1' or name()='h2']" \
		--publisher "Semaphore" \
		--book-producer "Semaphore" \
		--cover cover/cover.jpg \
		--epub-version 3 \
		--extra-css /data/styles/epub-kindle.css \
		--language "$(shell egrep '^language:' title.txt | cut -d: -f2 | sed -e 's/^[[:space:]]*//')" \
		--title "$(shell egrep '^title:' title.txt | cut -d: -f2 | sed -e 's/^[[:space:]]*//')" \
		--comments "$(shell egrep '^subtitle:' title.txt | cut -d: -f2 | sed -e 's/^[[:space:]]*//')" \
		--authors "$(shell egrep '^author:' title.txt | cut -d: -f2 | sed -e 's/^[[:space:]]*//')"

# mobipocket format
$(BUILD)/mobi/$(BOOKNAME).mobi: $(BUILD)/epub/$(BOOKNAME).epub
	mkdir -p $(BUILD)/mobi
	docker run $(EXTRA_OPTS) --rm --volume `pwd`:/data --entrypoint ebook-convert -w /data linuxserver/calibre $^ /data/$@ 

# amazon kindle format (for testing)
$(BUILD)/azw3/$(BOOKNAME).azw3: $(BUILD)/epub/$(BOOKNAME).epub
	mkdir -p $(BUILD)/azw3
	docker run --rm $(EXTRA_OPTS) --volume `pwd`:/data --entrypoint ebook-convert -w /data linuxserver/calibre $^ /data/$@ 

.PHONY: all book clean pdf html epub azw3 mobi
