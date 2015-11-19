module TypeChecker where

import AbsCPP
import PrintCPP
import ErrM

type Env = (Sig, [Context])
type Sig = Map Id ([Type], Type)
type Context = Map Id Type

typecheck :: Program -> Err ()
typecheck p = return ()

inferExp :: Env -> 