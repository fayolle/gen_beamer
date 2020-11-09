# call it as make XXXXX.pdf where XXXXX.txt is the name of the presentation

%.tex: %.txt
	perl text_to_beamer.pl $< > $@

%.pdf: %.tex
	pdflatex $<
	pdflatex $<

clean:
	rm -rf *.aux *.log *.nav *.out *.pdf *.snm *.toc *.vrb
