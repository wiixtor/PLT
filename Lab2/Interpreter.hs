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
    (DFun _ _ _ stms) <- lookFun env (Id "main")
    evalStms env stms
    return ()

evalStms :: Env -> [Stm] -> IO Env
evalStms e [] = return e
evalStms e (s:ss) = do
    e' <- evalStm e s
    evalStms e' ss

evalStm :: Env -> Stm -> IO Env
evalStm e s = case s of
    SExp exp1 -> do
        (_, e') <- evalExp e exp1
        return e'
    SDecls typ ids -> do
        e' <- case typ of
            Type_int -> decl e ids $ VInt 0
            Type_bool -> decl e ids $ VBool False
            Type_double -> decl e ids $ VDouble 0.0
        return e'
    SInit _ id exp1 -> do
        (v, _) <- evalExp e exp1
        updateVal e id v
    SReturn exp1 -> do
        (v, e') <- evalExp e exp1
        return e'
    SWhile exp1 stm -> do
        (VBool b, env') <- evalExp e exp1
        if b == False then do
            return env'
        else do
            env'' <- evalStm env' stm
            evalStm env'' (SWhile exp1 stm) 
    SBlock stms -> do
        env' <- newBlock e
        env'' <- evalStms env' stms
        env''' <- popBlock env''
        return env'''
    SIfElse exp1 stm stm1 -> do
        (VBool b, env') <- evalExp e exp1 
        if b then
            evalStm env' stm
        else 
            evalStm env' stm1
  where 
    decl :: Env -> [Id] -> Value -> IO Env
    decl e [] val = return e
    decl e (id:ids) val = do
        e' <- newVal e id val
        decl e' ids val

-- all these gotta be fix
evalExp :: Env -> Exp -> IO (Value, Env)
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
        return (vAdd v0 v, env'')
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
        id <- getID exp1
        (v, env') <- evalExp env exp1
        env'' <- case v of 
            VInt i -> updateVal env' id (vAdd v (VInt 1))
            VDouble d -> updateVal env' id (vAdd v (VDouble 1.0))
        return (v, env'')
    EPostDecr exp1 -> do
        id <- getID exp1
        (v, env') <- evalExp env exp1
        env'' <- case v of 
            VInt i -> updateVal env' id (vSub v (VInt 1))
            VDouble d -> updateVal env' id (vSub v (VDouble 1.0))
        return (v, env'')

    EPreIncr exp1 -> do
        id <- getID exp1
        (v, env') <- evalExp env exp1
        case v of 
            VInt i -> do
                env'' <- updateVal env' id (vAdd v (VInt 1))
                return (vAdd v (VInt 1), env'')
            VDouble d -> do
                env'' <- updateVal env' id (vAdd v (VDouble 1.0))
                return (vAdd v (VDouble 1.0), env'')
    EPreDecr exp1 -> do
        id <- getID exp1
        (v, env') <- evalExp env exp1
        case v of 
            VInt i -> do
                env'' <- updateVal env' id (vSub v (VInt 1))
                return (vSub v (VInt 1), env'')
            VDouble d -> do
                env'' <- updateVal env' id (vSub v (VDouble 1.0))
                return (vSub v (VDouble 1.0), env'')
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
        ((VBool v0), env') <- evalExp env exp0
        if v0 then do
            (v, env'') <- evalExp env' exp1
            return $ (vOr (VBool v0) v, env'')
        else do
            return $ ((VBool v0), env') 
    EOr exp0 exp1 -> do
        ((VBool v0), env') <- evalExp env exp0
        if v0 then 
            return $ ((VBool v0), env') 
        else do
            (v, env'') <- evalExp env' exp1
            return $ (vOr (VBool v0) v, env'')
    EAss exp0 exp1 -> do
        (v, env') <- evalExp env exp1
        id <- getID exp0
        env'' <- updateVal env' id v 
        return (v, env'')
    EApp fncid args -> do
        case fncid of
            (Id "printInt") -> do
                (VInt i, env') <- evalExp env (head args)
                putStrLn(show i)
                return ((VInt i), env')
            (Id "printDouble") -> do
                (VDouble d, env') <- evalExp env (head args)
                putStrLn(show d)
                return ((VDouble d), env')
            (Id "readInt") -> do
                i <- readAInt
                return (VInt i, env)
            (Id "readDouble") -> do
                d <- readADouble
                return (VDouble d, env)
            _ -> do
                env' <- halp args env
                (DFun _ _ _ stms) <- lookFun env' fncid
                evalFun env' stms

  where
    getID :: Exp -> IO Id 
    getID (EId id) = return id
    getID _ = fail "blurb"

    readAInt :: IO Integer
    readAInt = readLn
    readADouble :: IO Double
    readADouble = readLn

    halp :: [Exp] -> Env -> IO Env
    halp [] env = return env
    halp (e:es) env = do
        (v, e') <- evalExp env e
        halp es e'

evalFun :: Env -> [Stm] -> IO (Value, Env)
evalFun e [] = return (VVoid, e)
evalFun e ((SReturn ex):ss) = evalExp e ex
evalFun e (s:ss) = do
    e' <- evalStm e s
    evalFun e' ss

updateFun :: Env -> Def -> IO Env
updateFun (d, vs) (DFun typ id args stms) =
    if Map.member id d then
        fail "function already defined (updateFun)"
    else
        return (Map.insert id (DFun typ id args stms) d, vs)

newVal :: Env -> Id -> Value -> IO Env
newVal (d, v:vs) id val =
    return (d, Map.insert id val v : vs)

updateVal :: Env -> Id -> Value -> IO Env
updateVal (d, []) id val = fail $ " updateVal " ++ printTree (EId id)
updateVal (d, v:vs) id val =
    if Map.member id v then
        return (d, Map.insert id val v : vs)
    else do
        (d, vars) <- updateVal (d, vs) id val
        return (d, v : vars)

lookVar :: Env -> Id -> IO Value
lookVar (defs, []) id = fail "var not defined (lookVar)"
lookVar (defs, v:vs) id = do
    case Map.lookup id v of
        Just val -> return val
        Nothing -> lookVar (defs, vs) id

lookFun :: Env -> Id -> IO Def
lookFun env id = do
    case Map.lookup id (fst env) of
        Just f -> return f
        Nothing -> fail "fun not defined (lookFun)"

popBlock :: Env -> IO Env
popBlock (d, v:vs) = return (d,vs)

newBlock :: Env -> IO Env
newBlock (defs, vars) = return (defs, Map.empty : vars)

emptyEnv :: Env
emptyEnv = (Map.empty, [Map.empty])




vAdd :: Value -> Value -> Value
vAdd (VInt i0) (VInt i) = (VInt (i0 + i))
vAdd (VDouble d0) (VDouble d) = (VDouble (d0 + d))
vAdd _ _ = undefined

vSub :: Value -> Value -> Value
vSub (VInt i0) (VInt i) = (VInt (i0 - i))
vSub (VDouble d0) (VDouble d) = (VDouble (d0 - d))
vSub _ _ = undefined

vDiv :: Value -> Value -> Value
vDiv (VInt i0) (VInt i) = (VInt (quot i0 i))
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
