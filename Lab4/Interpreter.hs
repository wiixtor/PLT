module Interpreter where

import Data.Map (Map)
import qualified Data.Map as Map

import Control.Monad
import Control.Monad.State
import AbsFun
import System.Environment

data EvStrat = CallByValue | CallByName

type GEnv = (EvStrat, Functions)
type Functions = Map String Exp
type Env = Map String Value

data Value = VInt Integer | VClos Closure

data Closure = Clos Exp Env

interpret :: EvStrat -> Program -> IO ()
interpret evstrat (Prog defs) = do
    newGenv <- emptyGEnv
    e <- foldM
        updateFun
        newGenv
        defs
    exp <- lookFun e (Ident "main")
    eval e (Clos exp Map.empty)
    return ()
 

eval :: GEnv -> Closure -> IO Value
eval (strat, funs) (Clos e env) = ev (Clos e env)
  where
    ev :: Closure -> IO Value
    ev (Clos e env) = case e of
        EVar id -> return (VClos (Clos (EVar id) env))
        EInt int -> return (VInt int)
        EAdd exp1 exp2 -> do
            (VInt i1) <- ev (Clos exp1 env)
            (VInt i2) <- ev (Clos exp2 env)
            return (VInt (i1+i2))
        ESub exp1 exp2 -> do
            (VInt i1) <- ev (Clos exp1 env)
            (VInt i2) <- ev (Clos exp2 env)
            return (VInt (i1-i2))
        ELt exp1 exp2 -> do
            (VInt i1) <- ev (Clos exp1 env)
            (VInt i2) <- ev (Clos exp2 env)
            case (i1<i2) of 
                True -> return (VInt 1)
                False -> return (VInt 0)
        EIf exp1 exp2 exp3 -> do
            (VInt i1) <- ev (Clos exp1 env)
            case i1 of
                1 -> return ev (Clos exp2 env)
                0 -> return ev (Clos exp3 env)
        EAbs id exp -> undefined
        EApp f a -> undefined 


        {-do
            Clos (EAbs (Ident v) fbody) sub' <- ev (Clos f s)
            case strat of
                CallByValue -> do
                    a' <- ev (Clos a s)
                    ev (Clos fbody (Map.insert v a' sub'))
                CallByName ->
                    ev (Clos fbody (Map.insert v (Clos a s) sub'))

push :: Env -> IO Env
push (a, b, v) = do
    return $ (a, b, Map.empty : v)

pop :: Env -> IO Env
pop (a, b, (v:vs)) = do
    return $ (a, b, vs)
-}

emptyGEnv :: IO GEnv
emptyGEnv = return (CallByValue, Map.empty)

lookFun :: GEnv -> Ident -> IO Exp
lookFun (_, f) (Ident id) = do
    return $ f Map.! id 

updateFun :: GEnv -> Def -> IO GEnv
updateFun (a, f) (DDef (Ident funid) args exp) = do
    return (a, Map.insert funid exp f)

lookVal :: Env -> Ident -> IO Value
lookVal e (Ident i) = return $ (Map.!) e i 

updateVal :: Env -> Ident -> Value -> IO Env
updateVal e (Ident id) val = return $ Map.insert id val e






{-

main :: IO ()
main = do
    args <- getArgs
    let strat = case head args of
                    "-v" -> CallByValue
                    "-n" -> CallByName
    interpret strat (last args)
    -}