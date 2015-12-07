module Interpreter where

import AbsCPP
import PrintCPP
import ErrM

import Control.Monad
import Data.Map
import qualified Data.Map as Map

type Env = (Defs, [Vars])
type Defs = Map Id Def
type Vars = Map Id Value
data Value = VInt Integer | VDouble Double | VBool Bool | VVoid -- undefined?

{-
interpret :: Program -> IO ()
interpret p = putStrLn "no interpter"
-}

interpret :: Program -> IO ()
interpret (PDefs p) =   do
    env <- foldM
        updateFun
        emptyEnv
        p
    (DFun _ _ _ stms) <- lookFun env "main"
    evalStms env stms
    return ()

evalStms :: Env -> [Stm] -> Env
evalStms e [] = e
evalStms e (s:ss) = evalStms (evalStm e s) ss

evalStm :: Env -> Stm -> Env
evalStm e s = case s of
    SExp exp1 -> snd $ evalExp e exp1
    SDecls typ [id] -> e
    SInit _ id exp1 -> updateVal e id (fst $ evalExp e exp1)
    SReturn exp1 -> snd $ evalExp e exp1
    SWhile exp1 stm -> do
        (VBool b, env') <- evalExp e exp1
        if b == False then do
            return env'
        else do
            env'' <- evalStm env' stm
            evalStm env'' (SWhile exp1 stm) 

    SBlock stms -> evalStms (newBlock e) stms
    SIfElse exp1 stm stm1 -> do
        (VBool b, env') <- evalExp e exp1 
        if b then
            evalStm env' stm
        else 
            evalStm env' stm1



-- all these gotta be fix
evalExp :: Env -> Exp -> (Value, Env)
evalExp env x = case x of
    ETrue -> return (VBool True, env)
    EFalse -> return (VBool False, env)
    EInt n -> return (VInt n, env)
    EDouble d -> return (VDouble d, env)
    EId id -> do
        v <- lookVar env id 
        return (v, env)
    EPlus exp0 exp1 -> do 
        (v0, env') <- evalExp env exp0
        (v, env'') <- evalExp env' exp1
        val <- vAdd v0 v
        return (val, env'')
    EMinus exp0 exp1 -> do
        (v0, env') <- evalExp env exp0
        (v, env'') <- evalExp env' exp1
        return (vSub v0 v, env'')
    EDiv exp0 exp1 -> do 
        (v0, env') <- evalExp env exp0
        (v, env'') <- evalExp env' exp1
        return (vDiv v0 v, env'')
    ETimes exp0 exp1 -> do 
        (v0, env') <- evalExp env exp1
        (v, env'') <- evalExp env' exp1
        return (vMul v0 v, env'')
    EPostIncr exp1 -> do
        (v, env') <- evalExp env exp1
        case v of 
            VInt i -> return (vAdd v (VInt 1), env')
            VDouble d -> return (vAdd v (VDouble 1.0), env')
    EPostDecr exp1 -> do
        (v, env') <- evalExp env exp1
        case v of 
            VInt i -> return (vSub v (VInt 1), env')
            VDouble d -> return (vSub v (VDouble 1.0), env')
    EPreIncr exp1 -> do
        (v, env') <- evalExp env exp1
        case v of 
            VInt i -> return (vAdd v (VInt 1), env')
            VDouble d -> return (vAdd v (VDouble 1.0), env')
    EPreDecr exp1 -> do
        (v, env') <- evalExp env exp1
        case v of 
            VInt i -> return (vSub v (VInt 1), env')
            VDouble d -> return (vSub v (VDouble 1.0), env')
    ELt exp0 exp1 -> do
        (v0, env') <- evalExp env exp0
        (v, env'') <- evalExp env' exp1
        return $ (less v0 v, env'')
    EGt exp0 exp1 ->  do
        (v0, env') <- evalExp env exp0
        (v, env'') <- evalExp env' exp1
        return $ (more v0 v, env'')
    ELtEq exp0 exp1 -> do
        (v0, env') <- evalExp env exp0
        (v, env'') <- evalExp env' exp1
        return $ (lessEq v0 v, env'')
    EGtEq exp0 exp1 ->  do
        (v0, env') <- evalExp env exp0
        (v, env'') <- evalExp env' exp1
        return $ (moreEq v0 v, env'')
    EEq  exp0 exp1 -> do
        (v0, env') <- evalExp env exp0
        (v, env'') <- evalExp env' exp1
        return $ (equals v0 v, env'')
    ENEq exp0 exp1 -> do
        (v0, env') <- evalExp env exp0
        (v, env'') <- evalExp env' exp1
        return $ (notEq v0 v, env'')
    EAnd exp0 exp1 -> do
        (v0, env') <- evalExp env exp0
        (v, env'') <- evalExp env' exp1
        return $ (vAnd v0 v, env'')
    EOr exp0 exp1 -> do
        (v0, env') <- evalExp env exp0
        (v, env'') <- evalExp env' exp1
        return $ (vOr v0 v, env'')
    EAss exp0 exp1 -> do
        (v, env') <- evalExp env exp1
        (EId id) <- getID exp0
        env'' <- updateVal env' id v 
        return env''
    EApp fncid args -> undefined

  where
    getID :: Exp -> Err Id 
    getID (EId id) = return id
    getID _ = fail "blurb"

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
lookVar (defs, [var]) id = do
    case Map.lookup id var of
        Just v -> return v
        Nothing -> fail "var not defined (lookVar)"

lookFun :: Env -> Id -> Err Def
lookFun env id = do
    case Map.lookup id (fst env) of
        Just f -> return f
        Nothing -> fail "fun not defined (lookFun)"

popBlock :: Env -> Err Env
popBlock (d, v:vs) = return (d,vs)

newBlock :: Env -> Err Env
newBlock (defs, vars) = return (defs, Map.empty : vars)

emptyEnv :: Env
emptyEnv = (Map.empty, [])




vAdd :: Value -> Value -> Value
vAdd (VInt i0) (VInt i) = (VInt (i0 + i))
vAdd (VDouble d0) (VDouble d) = (VDouble (d0 + d))
vAdd _ _ = undefined

vSub :: Value -> Value -> Value
vSub (VInt i0) (VInt i) = (VInt (i0 - i))
vSub (VDouble d0) (VDouble d) = (VDouble (d0 - d))
vSub _ _ = undefined

vDiv :: Value -> Value -> Value
vDiv (VInt i0) (VInt i) = (VInt (i0 / i))
vDiv (VDouble d0) (VDouble d) = (VDouble (d0 / d))
vDiv _ _ = undefined

vMul :: Value -> Value -> Value
vMul (VInt i0) (VInt i) = (VInt (i0 * i))
vMul (VDouble d0) (VDouble d) = (VDouble (d0 * d))
vMul _ _ = undefined

less :: Value -> Value -> Value
less (VInt i0) (VInt i) = VBool (i0 < i)
less (VDouble d0) (VDouble d) = VBool (d0 < d)
less _ _ = undefined

lessEq :: Value -> Value -> Value
lessEq (VInt i0) (VInt i) = VBool (i0 <= i)
lessEq (VDouble d0) (VDouble d) = VBool (d0 <= d)
lessEq _ _ = undefined

more :: Value -> Value -> Value
more (VInt i0) (VInt i) = VBool (i0 > i)
more (VDouble d0) (VDouble d) = VBool (d0 > d)
more _ _ = undefined

moreEq :: Value -> Value -> Value
moreEq (VInt i0) (VInt i) = VBool (i0 >= i)
moreEq (VDouble d0) (VDouble d) = VBool (d0 >= d)
moreEq _ _ = undefined

equals :: Value -> Value -> Value
equals (VInt i0) (VInt i) = VBool (i0 == i)
equals (VDouble d0) (VDouble d) = VBool (d0 == d)
equals _ _ = undefined

notEq :: Value -> Value -> Value
notEq (VInt i0) (VInt i) = VBool (i0 /= i)
notEq (VDouble d0) (VDouble d) = VBool (d0 /= d)
notEq _ _ = undefined

vAnd :: Value -> Value -> Value
vAnd (VBool b0) (VBool b) = VBool (b0 && b)
vAnd _ _ = undefined

vOr :: Value -> Value -> Value
vOr (VBool b0) (VBool b) = VBool (b0 || b)
vOr _ _ = undefined
