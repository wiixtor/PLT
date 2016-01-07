module Interpreter where

import Data.Map (Map)
import qualified Data.Map as Map

import Control.Monad
import Control.Monad.State
import AbsFun
import System.Environment

data EvStrat = CallByValue | CallByName

type Env = (EvStrat, Functions, Values)
type Functions = Map String Exp
type Values = [Map String Value]


data Value = VInt Integer | VAbs String Exp Substitution

data Closure = Clos Exp Substitution

type Substitution = Map String Closure

interpret :: EvStrat -> Program -> IO ()
interpret evstrat (Prog defs) = do
    newenv <- emptyEnv
    e <- foldM
        updateFun
        newenv
        defs
    exp <- lookFun e (Ident "main")
    return ()
 

eval :: Env -> Closure -> IO Closure
eval (strat, funs, vals) (Clos e s) = ev (Clos e s)
  where
    ev :: Closure -> IO Closure
    ev = case e of
        EVar id -> undefined
        EInt int -> undefined -- Clos (Eint int) sueb
        EAdd exp1 exp2 -> undefined
        ESub exp1 exp2 -> undefined
        ELt exp1 exp2 -> undefined
        EIf exp1 exp2 exp3 -> undefined
        EAbs id exp -> undefined
        EApp f a -> undefined {-do
            Clos (EAbs (Ident v) fbody) sub' <- ev (Clos f s)
            case strat of
                CallByValue -> do
                    a' <- ev (Clos a s)
                    ev (Clos fbody (Map.insert v a' sub'))
                CallByName ->
                    ev (Clos fbody (Map.insert v (Clos a s) sub'))
-}
push :: Env -> IO Env
push (a, b, v) = do
    return $ (a, b, Map.empty : v)

pop :: Env -> IO Env
pop (a, b, (v:vs)) = do
    return $ (a, b, vs)

emptyEnv :: IO Env
emptyEnv = return (CallByValue, Map.empty, (Map.empty:[]))

lookFun :: Env -> Ident -> IO Exp
lookFun (_, f, _) (Ident id) = do
    return $ f Map.! id 

updateFun :: Env -> Def -> IO Env
updateFun (a, f, b) (DDef (Ident funid) args exp) = do
    return (a, Map.insert funid exp f, b)

lookVal :: Env -> Ident -> IO Value
lookVal (a, b, vs) (Ident id) 
    | null vs   = fail "value unfound" 
    | otherwise =
        case Map.lookup id (head vs) of
            Nothing -> lookVal (a, b, (tail vs)) (Ident id)
            Just x  -> return x

updateVal :: Env -> Ident -> Value -> IO Env
updateVal (a, b, (v:vs)) (Ident id) val = do
    return (a, b, Map.insert id val v : vs)








main :: IO ()
main = do
    args <- getArgs
    let strat = case head args of
                    "-v" -> CallByValue
                    "-n" -> CallByName
    interpret strat (last args)