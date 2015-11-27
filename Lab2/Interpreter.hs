module Interpreter where

import AbsCPP
import PrintCPP
import ErrM

import Control.Monad
import qualified Data.Map as M

VInteger. Value ::= Integer ;
VDouble. Value ::= Double ;
VVoid. Value ::= ;
VUndefined. Value ::= ;

{-
<Value,Env> eval (Env env, Exp e)
Env exec (Env env, Statement s)
Void exec (Program p) //interpret
Value look (Ident x, Env env)
Fun look (Ident x, Env env)
Env extend (Env env, Ident x, Value v)
Env extend (Env env, Definition d)
Env push (Env env)
Env pop (Env env)
Env empty ()
-}

interpret :: Program -> IO ()
interpret p = putStrLn "no interpreter yet"