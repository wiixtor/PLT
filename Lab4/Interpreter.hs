module Main where

import Data.Map (Map)
import qualified Data.Map as Map

import Control.Monad
import Control.Monad.State

import System.Environment (getArgs)
import System.Exit (exitFailure)

import AbsFun
import LexFun
import ParFun
import ErrM



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
    (VInt v)<- eval e (Clos exp Map.empty)
    print v
 

eval :: GEnv -> Closure -> IO Value
eval (strat, funs) (Clos e env) = ev (Clos e env)
  where
    ev :: Closure -> IO Value
    ev (Clos e env) = case e of
        EVar id -> do
            x <- lookVal env id
            return x
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
                0 -> do
                    c <- ev (Clos exp3 env)
                    return c
                _ -> do
                    c <- ev (Clos exp2 env)
                    return c
        EAbs id exp -> do
          --  val <- ev (Clos exp env)
            return (VClos (Clos (EAbs id) exp) env)
        EApp (EAbs x exp) a -> do
            --VClos (Clos (EAbs (Ident v) fbody) env') <- ev (Clos f env)
            v <- ev (Clos a env)
            env' <- updateVal env x v
            case strat of
                CallByValue -> do
                    a' <- ev (Clos a env)
                    e' <- updateVal env' x a'
                    ev (Clos exp e')
                CallByName -> do
                    e' <- (updateVal env' x (VClos (Clos a env)))
                    ev (Clos exp e')
        _ -> fail "EAbs fail"

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




-- driver

check :: EvStrat ->  String -> IO ()
check m s = do
  case pProgram (myLexer s) of
    Bad err  -> do
      putStrLn "SYNTAX ERROR"
      exitFailure
    Ok  tree -> do
      interpret m tree

main :: IO ()
main = do
  args <- getArgs
  let mode = case head args of
                "-v" -> CallByValue
                "-n" -> CallByName
  readFile (last args) >>= check mode