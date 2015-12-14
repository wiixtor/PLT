module CodeGenerator where 

import AbsCPP
import PrintCPP
import ErrM

import Control.Monad

import Data.Map (Map)
import qualified Data.Map as Map

import Control.Monad.State

data FunSig = FunSig 
{
    fsIntyps :: [Type],
    fsOuttyp :: Type
}

data Env = Env 
{
    envSignature :: Map String FunSig   
}

--state transformer monad
type M a = StateT Env IO

updateFun :: String -> FunSig -> M ()
updateFun id sig = do
    env <- get 
    put $ env { envSignature = Map.insert id sig (envSignature env) }

lookupFun :: String -> M FunSig
lookupFun id = do
    env <- get
    return $ envSignature env Map.! id 

emptyEnv :: Env 
emptyEnv =
    Env 
    {
        envSignature = Map.empty
    }

emit :: String -> M ()
emit line = 
    lift $ putStrLn line

generateCode :: Program -> IO()
generateCode (PDefs defs) = do
    env <- emptyEnv
    evalStateT f env -- Monad function
    return ()
    where 
        f = do
            updateFun "printInt"  (FunSig {fsIntyps = [Type_int], fsOuttyp = void})
            -- skipping adding user defined functions to signature
            mapM (\DFun outtyp id args stms) -> do 
                -- skipping adding new local context and functino arguments
                generateStms stms )
                defs
            return ()
generateStms :: [Stm] -> M ()
generateStms stms = do
    mapM generateStm stms 
    return ()

generateStm :: Stm -> M ()
generateStm (SExp exp) = do
    generateExp exp
    emit "pop"

generateExp :: Exp -> M ()
generateExp (EInt int) = do
    emit $ "ldc " ++ show int
generateExp (EPlus exp1 exp2) = do
    generateExp exp1
    generateExp exp2
    emit $ "iadd"
generateExp (EApp (Id fcnid) args) = do 
    mapM generateExp args
    fsig <- lookupFun fcnid
    emit $ "invokestatic runtime/printInt(I)V" -- assuming always calling printInt (Lecture running out of time)
    if (fsOuttyp fsig == Type_void) then
        emit "bipush 0"
    else
        return () 

--emit "return " somewheqre