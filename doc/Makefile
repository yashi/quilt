all : quilt.pdf quilt-rus.pdf

quilt.ps : quilt.dvi
	dvips -t letter -o $@ $<

quilt.aux: main.tex
	pdflatex --draftmode --jobname=quilt -t letter $<

quilt.pdf: main.tex quilt.aux
	pdflatex --jobname=quilt -t letter $<

quilt.dvi : main.tex
	latex $< && \
	mv main.dvi $@

quilt-rus.ps : quilt-rus.dvi
	dvips -t letter -o $@ $<

quilt-rus.aux: main-rus.tex
	pdflatex --draftmode --jobname=quilt-rus -t letter $<

quilt-rus.pdf: main-rus.tex quilt-rus.aux
	pdflatex --jobname=quilt-rus -t letter $<

quilt-rus.dvi : main-rus.tex
	latex $< && \
	mv main-rus.dvi $@

clean:
	rm -f {main,quilt}.{dvi,log,aux} {main,quilt}-rus.{dvi,log,aux}

distclean: clean
	rm -f quilt.{ps,pdf,dvi} quilt-rus.{ps,pdf,dvi}
