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
	EInt n -> return Type_int
	EId id -> lookVar env id
	EPlus exp0 exp -> inferArithmBin env exp0 exp

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