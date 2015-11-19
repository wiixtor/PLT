module TypeChecker where

import AbsCPP
import PrintCPP
import ErrM
import Data.Map

type Env = (Sig, [Context])
type Sig = Map Id ([Type], Type)
type Context = Map Id Type

typecheck :: Program -> Err ()
typecheck p = return ()

checkStm :: Env -> Type -> Stm -> Err Env
checkStm env val x = case x of
	SExp exp -> do
		inferExp env exp
		return env
	SDecls type' x ->
		updateVar env id type'
	SWhile exp stm -> do
		checkExp env Type_bool exp
		checkStm env val stm

{- 
 | SInit Type Id Exp
 | SReturn Exp
 | 
 | SBlock [Stm]
 | SIfElse Exp Stm Stm -}

checkExp :: Env -> Type -> Exp -> Err ()
checkExp env typ exp = do
	typ2 <- inferExp env exp
	if (typ2 == typ) then
		return ()
	else
		fail $ "type of " ++ printTree exp

inferExp :: Env -> Exp -> Err Type
inferExp env x = case x of
	ETrue -> return Type_bool
	EFalse -> return Type_bool
	EInt n -> return Type_int
	EDouble d -> return Type_double
	EId id -> lookVar env id
	EPlus exp0 exp -> inferArithmBin env exp0 exp
	EMinus exp0 exp -> inferArithmBin env exp0 exp
	EDiv exp0 exp -> inferArithmBin env exp0 exp
	ETimes exp0 exp -> inferArithmBin env exp0 exp

{- 
 | EApp Id [Exp]
 | EPostIncr Exp
 | EPostDecr Exp
 | EPreIncr Exp
 | EPreDecr Exp

 | ELt Exp Exp
 | EGt Exp Exp
 | ELtEq Exp Exp
 | EGtEq Exp Exp
 | EEq Exp Exp
 | ENEq Exp Exp
 | EAnd Exp Exp
 | EOr Exp Exp
 | EAss Exp Exp -}

inferArithmBin :: Env -> Exp -> Exp -> Err Type
inferArithmBin env a b = do
	typ <- inferExp env a
	if elem typ [Type_int, Type_double] then do
		checkExp env b typ
	else
		fail $ "type of expression " ++ printTree exp -- 

lookVar :: Env -> Id -> Err Type
lookVar = undefined

lookFun :: Env -> Id -> Err ([Type],Type)
lookFun = undefined

updateVar :: Env -> Id -> Type -> Err Env
updateVar = undefined

updateFun :: Env -> Id -> ([Type],Type) -> Err Env
updateFun = undefined

newBlock :: Env -> Err Env
newBlock = undefined

emptyEnv :: Env
emptyEnv = ((), [])