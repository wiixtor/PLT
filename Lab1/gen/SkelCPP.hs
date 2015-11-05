module SkelCPP where

-- Haskell module generated by the BNF converter

import AbsCPP
import ErrM
type Result = Err String

failure :: Show a => a -> Result
failure x = Bad $ "Undefined case: " ++ show x

transId :: Id -> Result
transId x = case x of
  Id str  -> failure x


transIdT :: IdT -> Result
transIdT x = case x of
  IdT str  -> failure x


transProgram :: Program -> Result
transProgram x = case x of
  PDefs defs  -> failure x


transDef :: Def -> Result
transDef x = case x of
  DFun type' id arglist body  -> failure x


transBody :: Body -> Result
transBody x = case x of
  EBody  -> failure x
  Body stms  -> failure x


transArgList :: ArgList -> Result
transArgList x = case x of
  Args args  -> failure x


transArg :: Arg -> Result
transArg x = case x of
  TArg type'  -> failure x
  IdArg type' id  -> failure x
  DArg type' id exp  -> failure x
  CArg arg  -> failure x


transStm :: Stm -> Result
transStm x = case x of
  SExp exp  -> failure x
  SDec type' id exp  -> failure x
  SDecs type' id ids exp  -> failure x
  SReturn exp  -> failure x
  SWhile exp stm  -> failure x
  SDo stm exp  -> failure x
  SFor stm1 exp2 exp3 stm4  -> failure x
  SIf exp stm  -> failure x


transExp :: Exp -> Result
transExp x = case x of
  EInt n  -> failure x
  EString str  -> failure x
  EQConst idt idts  -> failure x
  ELShift exp1 exp2  -> failure x


transType :: Type -> Result
transType x = case x of
  TInt n  -> failure x


