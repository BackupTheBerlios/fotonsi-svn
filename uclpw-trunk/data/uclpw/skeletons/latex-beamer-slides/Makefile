all: %{APPLICATION_ID}.pdf

%{APPLICATION_ID}.pdf: %{APPLICATION_ID}.tex
	pdflatex %{APPLICATION_ID}.tex
	pdflatex %{APPLICATION_ID}.tex

clean:
	$(RM) %{APPLICATION_ID}.{aux,log,nav,out,pdf,snm,toc,vrb}
