all:
	bnfc Fun.cf
	happy -gca ParFun.y
	alex -g LexFun.x
	ghc --make Interpreter.hs -o lab4

clean:
	-rm -f lab2
	-rm -f *.log *.aux *.hi *.o *.dvi
	-rm -f DocCPP.ps

distclean: clean
	-rm -f DocCPP.* LexCPP.* ParCPP.* LayoutCPP.* SkelCPP.* PrintCPP.* TestCPP.* AbsCPP.* TestCPP ErrM.* SharedString.* CPP.dtd XMLCPP.*

