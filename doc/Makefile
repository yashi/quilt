all : quilt.pdf

quilt.ps : quilt.dvi
	dvips -t letter -o $@ $<

quilt.pdf: main.tex
	pdflatex -t letter $< && \
	mv main.pdf $@

quilt.dvi : main.tex
	latex $< && \
	mv main.dvi $@

clean:
	rm -f main.{dvi,log,aux}

distclean: clean
	rm -f quilt.{ps,pdf,dvi}
