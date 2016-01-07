module Interpreter where

import Data.Map (Map)
import qualified Data.Map as Map

import Control.Monad
import Control.Monad.State
import AbsFun

data EvStrat = CallByValue | CallByName

data Env = Env {
    envStrat :: EvStrat,
    envFuns :: Map String Exp,
    envValues :: [Map String Value]
}

data Value = VInt Integer | VAbs String Exp Substitution

data Closure = Clos Exp Substitution

type Substitution = Map String Closure

--state transformer monad
type M a = StateT Env IO a

interpret :: EvStrat -> Program -> M ()
interpret evstrat (Prog defs) = do
    evalStateT f emptyEnv
    return ()
  where
    f :: M ()
    f = do
        mapM
            updateFun
            defs
        exp <- lookFun (Ident "main")
       -- eva lexp
        return ()


{- eval :: Env -> Closure -> Closure
eval genv clos = ev clos
  where
    ev :: Closure -> Closure
    ev = case clos of
        EVar id -> undefined
        EInt int -> undefined -- Clos (Eint int) sueb
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
-}
push :: M ()
push = do
    env <- get
    put $ Env { envValues = (Map.empty : (envValues env)) }

pop :: M ()
pop = do
    env <- get
    put $ Env {envValues = (tail $ envValues env)}

emptyEnv :: Env
emptyEnv = Env {envStrat = CallByValue, envFuns = Map.empty}

lookFun :: Ident -> M Exp
lookFun (Ident id) = do
    env <- get
    return $ envFuns env Map.! id 

updateFun :: Def -> M ()
updateFun (DDef (Ident funid) args exp) = do
    env <- get
    put $ env { envFuns = Map.insert funid exp (envFuns env) }

lookVal :: Ident -> M Value
lookVal (Ident id) = do
    env <- get
    return $ (head $ envValues env) Map.! id 

updateVal :: Ident -> Value -> M ()
updateVal (Ident id) val = do
    env <- get
    put $ env { envValues = (Map.insert id val (head $ (envValues env))) : (tail (envValues env) )}
