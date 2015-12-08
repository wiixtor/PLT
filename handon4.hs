module Interpreter where

import Data.Map (Map)
import qualified Data.Map as Map

import AbsFun

data EvStrat = CallByValue | CallByName

data GlobEnv = GlobEnv {
	genvEvStrat :: EvStrat,
	genvFcns :: Map String Exp

}

-- data Value = VInt Integer | VAbs String Exp Substitution

data Closure = Clos Exp Substitution

type Substitution = Map String Closure



interpret :: EvStrat -> Program -> IO ()
interpret evstrat (Prog defs) = undefined


eval :: GlobEnv -> Closure -> Closure
eval genv clos = ev clos
  where
  	ev :: Closure -> Closure
  	ev = case clos of
  		EApp f a ->
  			let Clos (Eabs (Ident v) fbody) sub' = ev (Clos f sub)
  			in case genvEvStrat genv of
  				CallByValue ->
  					let a' = ev (Clos a sub)
  					in ev (Clos fbody (Map.insert v a' sub'))
        		CallByName ->

        			ev (Clos fbody (Map.insert v (Clos a sub) sub'))