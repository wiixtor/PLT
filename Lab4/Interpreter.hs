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
type Functions = Map String Value
type Env = Map String Value

data Value = VInt Integer | VClos Closure
  deriving Show

data Closure = Clos Exp Env
  deriving Show

interpret :: EvStrat -> Program -> IO ()
interpret evstrat (Prog defs) = do
    newGenv <- emptyGEnv
    e <- foldM
        updateFun
        newGenv
        defs
    (VClos clos) <- lookFun e (Ident "main")
    val <- eval e clos
    case val of
        (VInt v) -> print v
        (VClos (Clos ex en)) -> fail "main returns closure"
 

eval :: GEnv -> Closure -> IO Value
eval (strat, funs) (Clos e env) = ev (Clos e env)
  where
    ev :: Closure -> IO Value
    ev (Clos e env) = case e of
        EVar id -> do
            x <- lookVal env funs id
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
            return (VClos (Clos (EAbs id exp) env))
        EApp funcid args -> do
            VClos (Clos (EAbs funcid' exp) env') <- ev (Clos funcid env)
            --argvalue <- ev (Clos args env)
            --env' <- updateVal env funcid' argvalue
            case strat of
                CallByValue -> do
                    argvalue' <- ev (Clos args env')
                    env'' <- updateVal env' funcid' argvalue'
                    ev (Clos exp env'')
                CallByName -> do
                    env'' <- (updateVal env' funcid' (VClos (Clos args env')))
                    ev (Clos exp env'')

emptyGEnv :: IO GEnv
emptyGEnv = return (CallByValue, Map.empty)

lookFun :: GEnv -> Ident -> IO Value
lookFun (_, f) (Ident id) = 
    case Map.lookup id f of
        Just v -> return v
        Nothing -> fail $ "function doesn't exist: " ++ id ++ " in: " ++ (show f)

updateFun :: GEnv -> Def -> IO GEnv
updateFun (a, f) (DDef (Ident funid) args exp) = do
    let exp' = constructFun args exp
    return (a, Map.insert funid (VClos (Clos exp' Map.empty)) f)

constructFun :: [Ident] -> Exp -> Exp
constructFun [] e = e
constructFun (x:xs) e = EAbs x (constructFun xs e)

lookVal :: Env -> Functions -> Ident -> IO Value
lookVal e funs (Ident i) = 
    case Map.lookup i e of
        Just v -> return v
        Nothing -> 
            case Map.lookup i funs of
                Just exp -> return exp
                Nothing -> fail $ "variable not exist: " ++ i ++ " Env: " ++ (show e) ++ " GEnv: " ++ (show funs)

    --return $ (Map.!) e i 

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