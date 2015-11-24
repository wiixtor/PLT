module TypeChecker where 

import AbsCPP
import PrintCPP
import ErrM
import Data.Map (Map)
import qualified Data.Map as Map

type Env = (Sig, [Context])
type Sig = Map Id ([Type], Type)
type Context = Map Id Type

lookupFun :: Env -> Id -> Err ([Type], Type)
lookupFun env fid =
	case Map-Lookup fid (fst env) of
        Just funtyps -> return funtyps
        Nothing  -> fail "Function name not declared"

updateVar :: Env -> Id -> Type -> Err Env
updateVar (Sig, topctx : restctxs) v typ =
    if Map.memver v topctx then
        fail "Variable already declared in current block"
    else 
        return (Sig, Map.insert v typ topctx : restctxs)


updateFun :: Env -> Id -> ([Type], Type) -> Err Env
updateFun (sig, ctxs) f funtyps =
    if map.member f sig then 
        fail $ "blabal"
    else 
        return (sig, map.insert f funtyps sig, ctxs)

newBlock :: Env -> Err Env
newBlock = (sig, ctxs) = (sig, Map.empty : ctxs)

emptyEnv :: Env
emptyEnv = (Map.empty, [])

typecheck :: Program -> Err ()
typecheck (PDefs p) = do
    builtenv <- foldM
    (\env (id, typs) -> updateFun env (Id id) typs)
    emptyEnv
    [("printInt", ([Type_int], Type_void))]
    -- skipping functions
    let globalenv = builtenv
    mapM
    (\(DFun outtyp id args _) ->
        let 
            retType = case outtyp of
                Type_void -> Nothing
                _ -> Just outtyp
        in do 
            fbdyenv <- foldM (\env (ADecl atyp aid) -> updateVar env aid atyp )
            newBlock globalenv
        typecheckStms fbdyenv retType stms
    )
    defs
return ()

typecheckStms :: Env -> Maybe Type -> [Stm] -> Err ()
typecheckStms env (Just retType) [laststm] =
    case laststm of
        SReturn exp ->
        typecheckExp env retType exp
    _ ->
        fail "Return statement expected"
typecheckStms env Nothing [] = 
    return ()
typecheckStms env (Just _) [] =
    fail "Return statement expected"
typecheckStms env retType (stm : stms) = do
    env' <- typecheckStms env stm
    typecheckStms env' retType stms

typecheckStms :: Env -> Stm -> Err Env
typecheckStms  _ (SReturn _) = fail "Return statement not expected here"
typecheckStms env (SExp exp) = do
    _ <- typeinfer env exp 
    return env

typecheckExp :: Env -> Type -> Exp -> Err ()
typecheckExp env typ exp = do
    inftyp <- typeinfer env exp
    if typ == inftyp then
        return ()
    else 
        fail $ "expected type" ++ printTree typ ++ ", but found type " ++ printTree inftyp ++ "."

