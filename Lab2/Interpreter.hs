module Interpreter where

import AbsCPP
import PrintCPP
import ErrM

import Control.Monad
import qualified Data.Map as M

type Env = (Defs, [Vars])
type Defs = Map Id Def
type Vars = Map Id Value
data Value = VInt Integer | VDouble DOuble | VBool Bool | VVoid -- undefined?


{-
VInteger. Value ::= Integer ;
VDouble. Value ::= Double ;
VVoid. Value ::= ;
VUndefined. Value ::= ;

	<Value,Env> eval (Env env, Exp e)		eval
	Env exec (Env env, Statement s)
	Void exec (Program p) 					interpret
	Value look (Ident x, Env env)			lookVar
	Fun look (Ident x, Env env)				lookFun
	Env extend (Env env, Ident x, Value v)	updateVal
	Env extend (Env env, Definition d)		updateFun
	Env push (Env env)						newBlock
	Env pop (Env env)						popBlock
	Env empty ()							emptyEnv
-}

interpret :: Program -> IO ()
interpret p = 	do
	env <- 

	builtInEnv <- foldM
		(\env (id, typs) -> updateFun env (Id id) typs)
		emptyEnv 
		[("printInt", ([Type_int], Type_void))
		,("printDouble", ([Type_double], Type_void))
		,("readInt", ([], Type_int))
		,("readDouble", ([], Type_double))]

	globalenv <- foldM
		(\env (DFun typ id args _) -> updateFun env id (argTypes args, typ))
		builtInEnv
		p


-- all these gotta be fix
eval :: Env -> Exp -> (Value, Env)
eval env x = case x of
	ETrue -> return (VBool True, env)
	EFalse -> return (VBool False, env)
	EInt n -> return (VInt n, env)
	EDouble d -> return (VDouble d, env)
	EId id -> lookVar env id
	EPlus exp0 exp -> inferArithmBin env exp0 exp
	EMinus exp0 exp -> inferArithmBin env exp0 exp
	EDiv exp0 exp -> inferArithmBin env exp0 exp
	ETimes exp0 exp -> inferArithmBin env exp0 exp
	EPostIncr exp -> inferExp env exp
	EPostDecr exp -> inferExp env exp
	EPreIncr exp -> inferExp env exp
	EPreDecr exp -> inferExp env exp
	ELt exp0 exp -> inferComparison env exp0 exp
	EGt exp0 exp -> inferComparison env exp0 exp
	ELtEq exp0 exp -> inferComparison env exp0 exp
	EGtEq exp0 exp -> inferComparison env exp0 exp
	EEq  exp0 exp -> inferComparison env exp0 exp
	ENEq exp0 exp -> inferComparison env exp0 exp
	EAnd exp0 exp -> inferBool env exp0 exp
	EOr exp0 exp -> inferBool env exp0 exp
	EAss exp0 exp -> inferAssign env exp exp0
	EApp fncid args -> do
			(intyps, outtyp) <- lookFun env fncid
			if length intyps == length args then do
				mapM 
					(\(typ, arg) -> checkExp env typ arg)
					(zip intyps args)
				return outtyp
			else
				fail "Function: Number of arguments did not match"


updateFun :: Env -> Def -> Err Env
updateFun (d, vs) (DFun typ id args stms) =
	if Map.member id d then
		fail "function already defined (updateFun)"
	else
		return (Map.insert id (DFun typ id args stms) d, vs)

updateVal :: Env -> Id -> Value -> Err Env
updateVal (d, v:vs) id val = 
	return (d, Map.insert id val v : vs)

lookVar :: Env -> Id -> Err Value
lookVar env id = do
	case Map.lookup id (snd env) of
		Just v -> return v
		Nothing -> fail "var not defined (lookVar)"

lookFun :: Env -> Id -> Err Def
lookFun env id = do
	case Map.lookup id (fst env) of
		Just f = return f
		Nothing = fail "fun not defined (lookFun)"

popBlock :: Env -> Err Env
popBlock (d, v:vs) = return (d,vs)

newBlock :: Env -> Err Env
newBlock (defs, vars) = return (defs, Map.empty : vars)

emptyEnv :: Env
emptyEnv = (Map.empty, [])