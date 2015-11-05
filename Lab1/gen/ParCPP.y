-- This Happy file was machine-generated by the BNF converter
{
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
module ParCPP where
import AbsCPP
import LexCPP
import ErrM

}

%name pProgram Program
%name pListDef ListDef
%name pDef Def
%name pBody Body
%name pArgList ArgList
%name pListArg ListArg
%name pListStm ListStm
%name pArg Arg
%name pStm Stm
%name pListId ListId
%name pExp Exp
%name pListIdT ListIdT
%name pType Type

-- no lexer declaration
%monad { Err } { thenM } { returnM }
%tokentype { Token }

%token 
 '(' { PT _ (TS _ 1) }
 ')' { PT _ (TS _ 2) }
 ',' { PT _ (TS _ 3) }
 '::' { PT _ (TS _ 4) }
 ';' { PT _ (TS _ 5) }
 '<<' { PT _ (TS _ 6) }
 '=' { PT _ (TS _ 7) }
 'const' { PT _ (TS _ 8) }
 'do' { PT _ (TS _ 9) }
 'for' { PT _ (TS _ 10) }
 'if' { PT _ (TS _ 11) }
 'return' { PT _ (TS _ 12) }
 'while' { PT _ (TS _ 13) }
 '{' { PT _ (TS _ 14) }
 '}' { PT _ (TS _ 15) }

L_integ  { PT _ (TI $$) }
L_quoted { PT _ (TL $$) }
L_Id { PT _ (T_Id $$) }
L_IdT { PT _ (T_IdT $$) }
L_err    { _ }


%%

Integer :: { Integer } : L_integ  { (read ( $1)) :: Integer }
String  :: { String }  : L_quoted {  $1 }
Id    :: { Id} : L_Id { Id ($1)}
IdT    :: { IdT} : L_IdT { IdT ($1)}

Program :: { Program }
Program : ListDef { PDefs (reverse $1) } 


ListDef :: { [Def] }
ListDef : {- empty -} { [] } 
  | ListDef Def { flip (:) $1 $2 }


Def :: { Def }
Def : Type Id ArgList Body { DFun $1 $2 $3 $4 } 


Body :: { Body }
Body : ';' { EBody } 
  | '{' ListStm '}' { Body (reverse $2) }


ArgList :: { ArgList }
ArgList : '(' ListArg ')' { Args $2 } 


ListArg :: { [Arg] }
ListArg : {- empty -} { [] } 
  | Arg { (:[]) $1 }
  | Arg ',' ListArg { (:) $1 $3 }


ListStm :: { [Stm] }
ListStm : {- empty -} { [] } 
  | ListStm Stm { flip (:) $1 $2 }


Arg :: { Arg }
Arg : Type { TArg $1 } 
  | Type Id { IdArg $1 $2 }
  | Type Id '=' Exp { DArg $1 $2 $4 }
  | 'const' Arg { CArg $2 }


Stm :: { Stm }
Stm : Exp ';' { SExp $1 } 
  | Type Id '=' Exp ';' { SDec $1 $2 $4 }
  | Type Id ',' ListId '=' Exp ';' { SDecs $1 $2 $4 $6 }
  | 'return' Exp ';' { SReturn $2 }
  | 'while' '(' Exp ')' Stm { SWhile $3 $5 }
  | 'do' Stm 'while' '(' Exp ')' ';' { SDo $2 $5 }
  | 'for' '(' Stm ';' Exp ';' Exp ')' Stm { SFor $3 $5 $7 $9 }
  | 'if' '(' Exp ')' Stm ';' { SIf $3 $5 }


ListId :: { [Id] }
ListId : {- empty -} { [] } 
  | Id { (:[]) $1 }
  | Id ',' ListId { (:) $1 $3 }


Exp :: { Exp }
Exp : Integer { EInt $1 } 
  | String { EString $1 }
  | IdT '::' ListIdT { EQConst $1 $3 }
  | Exp '<<' Exp { ELShift $1 $3 }


ListIdT :: { [IdT] }
ListIdT : {- empty -} { [] } 
  | IdT { (:[]) $1 }
  | IdT '::' ListIdT { (:) $1 $3 }


Type :: { Type }
Type : Integer { TInt $1 } 



{

returnM :: a -> Err a
returnM = return

thenM :: Err a -> (a -> Err b) -> Err b
thenM = (>>=)

happyError :: [Token] -> Err a
happyError ts =
  Bad $ "syntax error at " ++ tokenPos ts ++ 
  case ts of
    [] -> []
    [Err _] -> " due to lexer error"
    _ -> " before " ++ unwords (map (id . prToken) (take 4 ts))

myLexer = tokens
}

