module Interpreter where

import Data.Map (Map)
import qualified Data.Map as Map

import AbsFun

data EvStrat = CallByValue | CallByName

data Env = Env {
	envStrat :: EvStrat,
	envFuns :: Map String Exp

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
  		EApp f a ->
  			let Clos (Eabs (Ident v) fbody) sub' = ev (Clos f sub)
  			in case envStrat genv of
  				CallByValue ->
  					let a' = ev (Clos a sub)
  					in ev (Clos fbody (Map.insert v a' sub'))
        	    CallByName ->
        			ev (Clos fbody (Map.insert v (Clos a sub) sub'))



emptyEnv :: IO Env
emptyEnv = Env {envStrat = CallByValue, envFuns = Map.empty}

lookFun :: Env -> Ident -> IO Exp
lookFun env (Ident id) = undefined

updateFun :: Env -> Def -> IO Env
updateFun env (DDef funid args exp) = undefined

lookupVal :: Ident -> Env -> IO Value
lookupVal = undefined

updateVal :: Env -> Ident -> Value -> IO Env
updateVal = undefined
