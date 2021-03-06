{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}
module PrintCPP where

-- pretty-printer generated by the BNF converter

import AbsCPP
import Data.Char


-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : "," :ts -> showString t . space "," . rend i ts
    t  : ")" :ts -> showString t . showChar ')' . rend i ts
    t  : "]" :ts -> showString t . showChar ']' . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else (' ':s))

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: [a] -> Doc
  prtList = concatD . map (prt 0)

instance Print a => Print [a] where
  prt _ = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)



instance Print Id where
  prt _ (Id i) = doc (showString ( i))
  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])



instance Print Program where
  prt i e = case e of
   PDefs defs -> prPrec i 0 (concatD [prt 0 defs])


instance Print Def where
  prt i e = case e of
   DFun type' id args body -> prPrec i 0 (concatD [prt 0 type' , prt 0 id , doc (showString "(") , prt 0 args , doc (showString ")") , prt 0 body])
   DFunIn type' id args body -> prPrec i 0 (concatD [doc (showString "inline") , prt 0 type' , prt 0 id , doc (showString "(") , prt 0 args , doc (showString ")") , prt 0 body])
   DType type' id -> prPrec i 0 (concatD [doc (showString "typedef") , prt 0 type' , prt 0 id , doc (showString ";")])
   DDecInit dec -> prPrec i 0 (concatD [prt 0 dec , doc (showString ";")])
   DUsing qconst -> prPrec i 0 (concatD [doc (showString "using") , prt 0 qconst , doc (showString ";")])
   DStruc id decs -> prPrec i 0 (concatD [doc (showString "struct") , prt 0 id , doc (showString "{") , prt 1 decs , doc (showString "}") , doc (showString ";")])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print Dec where
  prt i e = case e of
   NormalDec type' ids -> prPrec i 1 (concatD [prt 0 type' , prt 0 ids])
   NormalInit type' ids exp -> prPrec i 0 (concatD [prt 0 type' , prt 0 ids , doc (showString "=") , prt 0 exp])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 1 x , doc (showString ";") , prt 1 xs])

instance Print Body where
  prt i e = case e of
   EBody  -> prPrec i 0 (concatD [doc (showString ";")])
   FBody stms -> prPrec i 0 (concatD [doc (showString "{") , prt 0 stms , doc (showString "}")])


instance Print Arg where
  prt i e = case e of
   TArg type' -> prPrec i 1 (concatD [prt 0 type'])
   IdArg type' id -> prPrec i 1 (concatD [prt 0 type' , prt 0 id])
   DArg type' id exp -> prPrec i 1 (concatD [prt 0 type' , prt 0 id , doc (showString "=") , prt 0 exp])
   CArg arg -> prPrec i 0 (concatD [doc (showString "const") , prt 1 arg])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print Stm where
  prt i e = case e of
   SExp exp -> prPrec i 0 (concatD [prt 0 exp , doc (showString ";")])
   SDec dec -> prPrec i 0 (concatD [prt 0 dec , doc (showString ";")])
   SConst dec -> prPrec i 0 (concatD [doc (showString "const") , prt 0 dec , doc (showString ";")])
   SReturn exp -> prPrec i 0 (concatD [doc (showString "return") , prt 0 exp , doc (showString ";")])
   SWhile exp stm -> prPrec i 0 (concatD [doc (showString "while") , doc (showString "(") , prt 0 exp , doc (showString ")") , prt 0 stm])
   SDo stm exp -> prPrec i 0 (concatD [doc (showString "do") , prt 0 stm , doc (showString "while") , doc (showString "(") , prt 0 exp , doc (showString ")") , doc (showString ";")])
   SFor dec exp0 exp stm -> prPrec i 0 (concatD [doc (showString "for") , doc (showString "(") , prt 0 dec , doc (showString ";") , prt 0 exp0 , doc (showString ";") , prt 0 exp , doc (showString ")") , prt 0 stm])
   SIf exp stm else' -> prPrec i 0 (concatD [doc (showString "if") , doc (showString "(") , prt 0 exp , doc (showString ")") , prt 0 stm , prt 0 else'])
   STypeD type' id -> prPrec i 0 (concatD [doc (showString "typedef") , prt 0 type' , prt 0 id , doc (showString ";")])
   SBlock body -> prPrec i 0 (concatD [prt 0 body])
   SStruct id decs -> prPrec i 0 (concatD [doc (showString "struct") , prt 0 id , doc (showString "{") , prt 1 decs , doc (showString "}") , doc (showString ";")])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print Else where
  prt i e = case e of
   RElse stm -> prPrec i 0 (concatD [doc (showString "else") , prt 0 stm])
   REmpty  -> prPrec i 0 (concatD [])


instance Print Exp where
  prt i e = case e of
   ELiteral literal -> prPrec i 16 (concatD [prt 0 literal])
   EQConst qconst -> prPrec i 16 (concatD [prt 0 qconst])
   EIndex exp0 exp -> prPrec i 15 (concatD [prt 15 exp0 , doc (showString "[") , prt 0 exp , doc (showString "]")])
   EFunc exp exps -> prPrec i 15 (concatD [prt 16 exp , doc (showString "(") , prt 0 exps , doc (showString ")")])
   EDot exp0 exp -> prPrec i 14 (concatD [prt 14 exp0 , doc (showString ".") , prt 15 exp])
   EArrow exp0 exp -> prPrec i 14 (concatD [prt 14 exp0 , doc (showString "->") , prt 15 exp])
   EIncR exp -> prPrec i 14 (concatD [prt 14 exp , doc (showString "++")])
   EDecR exp -> prPrec i 14 (concatD [prt 14 exp , doc (showString "--")])
   EIncL exp -> prPrec i 13 (concatD [doc (showString "++") , prt 13 exp])
   EDecL exp -> prPrec i 13 (concatD [doc (showString "--") , prt 13 exp])
   EDefr exp -> prPrec i 13 (concatD [doc (showString "*") , prt 13 exp])
   ENeg exp -> prPrec i 13 (concatD [doc (showString "!") , prt 13 exp])
   EMul exp0 exp -> prPrec i 12 (concatD [prt 12 exp0 , doc (showString "*") , prt 13 exp])
   EDiv exp0 exp -> prPrec i 12 (concatD [prt 12 exp0 , doc (showString "/") , prt 13 exp])
   ERem exp0 exp -> prPrec i 12 (concatD [prt 12 exp0 , doc (showString "%") , prt 13 exp])
   EAdd exp0 exp -> prPrec i 11 (concatD [prt 11 exp0 , doc (showString "+") , prt 12 exp])
   ESub exp0 exp -> prPrec i 11 (concatD [prt 11 exp0 , doc (showString "-") , prt 12 exp])
   ELShift exp0 exp -> prPrec i 10 (concatD [prt 10 exp0 , doc (showString "<<") , prt 11 exp])
   ERShift exp0 exp -> prPrec i 10 (concatD [prt 10 exp0 , doc (showString ">>") , prt 11 exp])
   ELesser exp0 exp -> prPrec i 9 (concatD [prt 10 exp0 , doc (showString "<") , prt 10 exp])
   EGreater exp0 exp -> prPrec i 9 (concatD [prt 10 exp0 , doc (showString ">") , prt 10 exp])
   ELesserE exp0 exp -> prPrec i 9 (concatD [prt 10 exp0 , doc (showString "<=") , prt 10 exp])
   EGreatE exp0 exp -> prPrec i 9 (concatD [prt 10 exp0 , doc (showString ">=") , prt 10 exp])
   EEquals exp0 exp -> prPrec i 8 (concatD [prt 9 exp0 , doc (showString "==") , prt 9 exp])
   EInEqual exp0 exp -> prPrec i 8 (concatD [prt 9 exp0 , doc (showString "!=") , prt 9 exp])
   EConj exp0 exp -> prPrec i 4 (concatD [prt 4 exp0 , doc (showString "&&") , prt 5 exp])
   EDisj exp0 exp -> prPrec i 3 (concatD [prt 3 exp0 , doc (showString "||") , prt 4 exp])
   EAss exp0 exp -> prPrec i 2 (concatD [prt 3 exp0 , doc (showString "=") , prt 2 exp])
   EAddAss exp0 exp -> prPrec i 2 (concatD [prt 3 exp0 , doc (showString "+=") , prt 2 exp])
   ESubAss exp0 exp -> prPrec i 2 (concatD [prt 3 exp0 , doc (showString "-=") , prt 2 exp])
   ECond exp0 exp1 exp -> prPrec i 2 (concatD [prt 3 exp0 , doc (showString "?") , prt 2 exp1 , doc (showString ":") , prt 2 exp])
   EExept exp -> prPrec i 0 (concatD [doc (showString "throw") , prt 2 exp])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print QConst where
  prt i e = case e of
   QConsts items -> prPrec i 0 (concatD [prt 0 items])


instance Print Item where
  prt i e = case e of
   IdItem id -> prPrec i 0 (concatD [prt 0 id])
   TypeItem id types -> prPrec i 0 (concatD [prt 0 id , doc (showString "<") , prt 1 types , doc (showString ">")])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString "::") , prt 0 xs])

instance Print Literal where
  prt i e = case e of
   LInt n -> prPrec i 0 (concatD [prt 0 n])
   LString strs -> prPrec i 0 (concatD [prt 0 strs])
   LChar c -> prPrec i 0 (concatD [prt 0 c])
   LFloat d -> prPrec i 0 (concatD [prt 0 d])


instance Print Type where
  prt i e = case e of
   TInt  -> prPrec i 1 (concatD [doc (showString "int")])
   TDouble  -> prPrec i 1 (concatD [doc (showString "double")])
   TVoid  -> prPrec i 1 (concatD [doc (showString "void")])
   TBool  -> prPrec i 1 (concatD [doc (showString "bool")])
   TQConst qconst -> prPrec i 1 (concatD [prt 0 qconst])
   TRef type' -> prPrec i 0 (concatD [prt 1 type' , doc (showString "&")])

  prtList es = case es of
   [x] -> (concatD [prt 1 x])
   x:xs -> (concatD [prt 1 x , doc (showString ",") , prt 1 xs])


