module TypeChecker where

import AbsCPP
import PrintCPP
import ErrM
import Data.Map (Map)
import qualified Data.Map as Map

type Env = (Sig, [Context])
type Sig = Map Id ([Type], Type)
type Context = Map Id Type

typecheck :: Program -> Err ()
typecheck (PDefs []) = do
	return ()
typecheck (PDefs p) = do
	builtenv <- foldM
		(\env (id, typs) -> updateFun env (ID id) typs)
		emptyEnv
		[("printInt", ([Type_int], Type_void))]
	let globalenv = builtenv
	mapM
		(\(DFun outtyp id args _) ->
			let 
				retType = case outtyp of
					Type_void -> Nothing
					_ -> Just outtyp
			in do
				fbodyenv <- 
					foldM (\env (ADecl atyp aid) ->
						updateVar env aid atyp
					)
					(newBlock globalenv)
				typcheckStms fbodyenv retType stms
			)
		defs
	return ()


typcheckStms :: Env -> Maybe Type -> [Stm] -> Err ()
typcheckStms env (Just retType) [laststm] =
	case laststm of
		SReturn exp -> checkExp env retType exp
		_ -> fail "not return"
typcheckStms env Nothing [] 	= return ()
typcheckStms env (Just _) [] 	= fail "fail"
typcheckStms env retType (s:ss) = do
	env' <- typcheckStm env s
	typcheckStms env' retType ss


typcheckStm :: Env -> Stm -> Err Env
typcheckStm _ (SReturn _) = fail "return wat"
typcheckStm env (SExp exp) = do
	_ <- inferExp env exp
	return env

checkDef :: Env -> Def -> Err ()
checkDef env def = undefined



{-checkStm :: Env -> Type -> Stm -> Err Env
checkStm env val x = case x of
	SExp exp -> do
		inferExp env exp
		return env
	SDecls dType x ->
		updateVar env id dType
	SWhile exp stm -> do
		checkExp env Type_bool exp
		checkStm env val stm
-}
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
		fail $ "type of " -- ++ printTree exp

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
	EAss exp0 exp -> checkExp env (inferExp env exp0) exp

{- 
 | EApp Id [Exp]
-}

inferBool :: Env -> Exp -> Exp -> Err Type
inferBool env a b = do
	typ <- inferExp env a
	if elem typ Type_bool then do
		checkExp env typ b
		return typ
	else
		fail $ "type of expression " ++ printTree exp -- 

inferArithmBin :: Env -> Exp -> Exp -> Err Type
inferArithmBin env a b = do
	typ <- inferExp env a
	if elem typ [Type_int, Type_double] then do
		checkExp env typ b
		return typ
	else
		fail $ "type of expression "-- ++ printTree exp -- 

inferComparison :: Env -> Exp -> Exp -> Err Type
inferComparison env a b = do
	typ <- inferExp env a
	if elem typ [Type_int, Type_double, Type_bool] then do
		checkExp env typ b
		return typ
	else
		fail $ "type of expression " -- ++ printTree exp -- 

lookVar :: Env -> Id -> Err Type
lookVar = undefined

lookFun :: Env -> Id -> Err ([Type],Type)
lookFun env fid = 
	case Map.lookup fid (fst env) of 
		Just funtyps -> return funtyps
		Nothing -> fail "function not defined"

updateVar :: Env -> Id -> Type -> Err Env
updateVar (s, c:cs) id typ = 
	if Map.member id c then
		fail "Already defined"
	else 
		return (s, Map.insert id typ : c : cs)
--	return $ (s, (Map.insert id typ):c)

updateFun :: Env -> Id -> ([Type],Type) -> Err Env
updateFun (sig, cs) f funtyps = 
	if Map.member f sig then
		fail
	else 
		return (Map.insert f funtyps sig, cs)

newBlock :: Env -> Err Env
newBlock (sig, cs) = (sig, Map.empty : cs)

emptyEnv :: Env
emptyEnv = (Map.empty, [])






typeinfer :: Env -> Exp -> Err Type
typeinfer env exp =
	case exp of
		Eplus exp1 exp2 -> do
			checkExp env Type_int exp1
			checkExp env Type_int exp2 -- add doubles
			return Type_int
		EInt _ -> 
			return Type_int
		EApp fncid arg -> do
			(inttyps, outtyp) <- lookFun env fncid
			if length inttyps == length args then do
				mapM 
					(\(typ, arg) -> checkExp env typ arg)
					(zip inttyps args)
				return outtyp
			else
				fail "something"