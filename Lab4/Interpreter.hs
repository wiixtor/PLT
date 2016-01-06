module Interpreter where

import Data.Map (Map)
import qualified Data.Map as Map

import AbsFun

data EvStrat = CallByValue | CallByName

data Env = Env {
    envStrat :: EvStrat,
    envFuns :: Map String Exp
    envValues :: [Map String Value]
}

data Value = VInt Integer | VAbs String Exp Substitution

data Closure = Clos Exp Substitution

type Substitution = Map String Closure



interpret :: EvStrat -> Program -> IO ()
interpret evstrat (Prog defs) = do
    newenv <- emptyEnv
    env <- foldM
        updateFun
        emptyEnv
        p
    (DDef _ _ exp) <- lookFun env (Ident "main")
    evalExp env exp
    return ()


eval :: Env -> Closure -> Closure
eval genv clos = ev clos
  where
    ev :: Closure -> Closure
    ev = case clos of
        EVar id -> undefined
        EInt int -> undefined -- Clos (Eint int) sub
        EAdd exp1 exp2 -> undefined
        ESub exp1 exp2 -> undefined
        ELt exp1 exp2 -> undefined
        EIf exp1 exp2 exp3 -> undefined
        EAbs id exp -> undefined
        EApp f a ->
            let Clos (Eabs (Ident v) fbody) sub' = ev (Clos f sub)
            in case envStrat genv of
                CallByValue ->
                    let a' = ev (Clos a sub)
                    in ev (Clos fbody (Map.insert v a' sub'))
                CallByName ->
                    ev (Clos fbody (Map.insert v (Clos a sub) sub'))

push :: Env -> IO Env 
push env = do
    put $ env { envValues = (Map.empty : (envValues env)) } }

pop :: Env -> IO Env
pop env = do
    put $ env {envValues = (tail $ envValues env)}

emptyEnv :: IO Env
emptyEnv = Env {envStrat = CallByValue, envFuns = Map.empty}

lookFun :: Env -> Ident -> IO Exp
lookFun env (Ident id) = do
    return $ envFuns env Map.! id 

updateFun :: Env -> Def -> IO Env
updateFun env (DDef funid args exp) = do
    put $ env { envFuns = Map.insert funid exp (envFuns env) }

lookVal :: Ident -> Env -> IO Value
lookVal (Ident id) env = do
    return $ head $ envValues env Map.! id 

updateVal :: Env -> Ident -> Value -> IO Env
updateVal env (Ident id) val = do
    put $ env { envValues = (Map.insert id val (head $ (envValues env))) : (tail (envValues env) )}
