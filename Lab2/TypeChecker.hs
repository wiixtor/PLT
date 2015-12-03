module TypeChecker where

import AbsCPP
import PrintCPP
import ErrM
import Data.Map (Map)
import qualified Data.Map as Map
import Control.Monad

type Env = (Sig, [Context])
type Sig = Map Id ([Type], Type)
type Context = Map Id Type

typecheck :: Program -> Err ()
typecheck (PDefs []) = do
    return ()
typecheck (PDefs [(DFun typ id arrgs stms)]) = do
    let p = [(DFun typ id arrgs stms)]

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

    mapM
        (\(DFun outtyp id args _) ->
            let 
                retType = case outtyp of
                    Type_void -> Nothing
                    _ -> Just outtyp
            in do
                envprep <- newBlock globalenv
                fbodyenv <- foldM 
                    (\env (ADecl atyp aid) -> updateVar env aid atyp)
                    envprep
                    args
                typcheckStms fbodyenv retType stms
            )
        p
    return ()
  where
    argTypes args = map (\(ADecl t _) -> t) args
typecheck _ = return ()


typcheckStms :: Env -> Maybe Type -> [Stm] -> Err ()
typcheckStms env (Just retType) (laststm:[]) =
    case laststm of
        SReturn exp -> checkExp env retType exp
        _ -> fail "Return statment expected"
typcheckStms env Nothing []     = return ()
typcheckStms env (Just _) []    = fail "Return statement expected"
typcheckStms env retType (s:ss) = do
    env' <- typcheckStm env s
    typcheckStms env' retType ss


typcheckStm :: Env -> Stm -> Err Env
typcheckStm _ (SReturn _) = fail "Return statment not expected here"
typcheckStm env (SExp exp) = do
    _ <- inferExp env exp
    return env
typcheckStm env (SDecls typ ids) = updateVars env ids typ
typcheckStm env (SInit typ id exp) = do
    env' <- updateVar env id typ
    checkExp env' typ exp
    return env'
typcheckStm env (SWhile exp stm) = do
    checkExp env Type_bool exp 
    env' <- typcheckStm env stm
    return env'
typcheckStm env (SBlock stms) = do
	env' <- newBlock env
	_ <- typcheckStms env' Nothing stms
	return env 
typcheckStm env (SIfElse exp stm0 stm1) = do 
    checkExp env Type_bool exp
    env' <- typcheckStm env stm0
    env'' <- typcheckStm env' stm1
    return env''


checkExp :: Env -> Type -> Exp -> Err ()
checkExp env typ exp = do
    typ2 <- inferExp env exp
    if (typ2 == typ) then
        return ()
    else
        fail $ "type of exp" -- ++ printTree exp

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

inferAssign :: Env -> Exp -> Exp -> Err Type
inferAssign env exp exp0 = do
    typ <- inferExp env exp
    typ0 <- inferExp env exp0
    if typ == typ0 then
        return typ
    else
        fail "Assingment: Types did not match"

inferBool :: Env -> Exp -> Exp -> Err Type
inferBool env a b = do
    typ <- inferExp env a
    if typ == Type_bool then do
        checkExp env typ b
        return typ
    else
        fail $ "Bools was not of type bool" -- ++ printTree exp -- 

inferArithmBin :: Env -> Exp -> Exp -> Err Type
inferArithmBin env a b = do
    typ <- inferExp env a
    if elem typ [Type_int, Type_double] then do
        checkExp env typ b
        return typ
    else
        fail $ "ArithBin: Types did not match or was not correct type"-- ++ printTree exp -- 

inferComparison :: Env -> Exp -> Exp -> Err Type
inferComparison env a b = do
    typ <- inferExp env a
    if elem typ [Type_int, Type_double, Type_bool] then do
        checkExp env typ b
        return typ
    else
        fail $ "tComapare: Types did not match or was not the correct type" -- ++ printTree exp -- 

lookVar :: Env -> Id -> Err Type
lookVar env varid = lookvar' (snd env) varid
  where
    lookvar' [] id      = fail " variable not defined "
    lookvar' (c:cs) id  = 
        case Map.lookup id c of
            Just typ -> Ok typ
            Nothing  -> lookvar' cs id

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
        return (s, Map.insert id typ c : cs)

updateVars :: Env -> [Id] -> Type -> Err Env
updateVars env [] _ = return env
updateVars env (i:is) typ = do
    env' <- updateVar env i typ
    updateVars env' is typ

updateFun :: Env -> Id -> ([Type],Type) -> Err Env
updateFun (sig, cs) f funtyps = 
    if Map.member f sig then
        fail "Function already defined"
    else 
        return (Map.insert f funtyps sig, cs)

newBlock :: Env -> Err Env
newBlock (sig, cs) = return (sig, Map.empty : cs)

emptyEnv :: Env
emptyEnv = (Map.empty, [])