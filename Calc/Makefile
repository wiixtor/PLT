all:
	happy -gca ParCalc.y
	alex -g LexCalc.x
	latex DocCalc.tex; dvips DocCalc.dvi -o DocCalc.ps
	ghc --make TestCalc.hs -o TestCalc
clean:
	-rm -f *.log *.aux *.hi *.o *.dvi
	-rm -f DocCalc.ps
distclean: clean
	-rm -f DocCalc.* LexCalc.* ParCalc.* LayoutCalc.* SkelCalc.* PrintCalc.* TestCalc.* AbsCalc.* TestCalc ErrM.* SharedString.* Calc.dtd XMLCalc.* Makefile*

