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

{-
Address look (Ident x)
FunType look (Ident f)
Void extend (Ident x, Size s)
Void extend (Definition d)
Void push () // new context when entering block
Void pop () // exit from block, discard new context
Void empty () // discard all variables
Label label () // get fresh code label
-}

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

emitLn :: String -> M ()
emitLn line = lift $ putStrLn line

emit :: String -> M ()
emit line = 
    lift $ putStr line

push :: Env -> IO Env
push envsigs = undefined -- return $ Map.empty : envsigs

pop :: Env -> IO Env
pop envsigs = undefined

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
    emitLn "pop"
generateStm (SDecls typ ids) = undefined
generateStm (SInit typ id exp) = do
    generateExp exp
    if (typ == Type_int) do
        emitLn "istore " ++ id
    else do
        emitLn "astore " ++ id
    -- emitLn "pop"
generateStm (SReturn exp) = do
    generateExp exp
    emitLn "return" -- return void atm
generateStm (SWhile exp stm) = do
    generateExp exp
    generateStm stm
    -- something
generateStm (SBlock stms) = do
    push
    generateStms stms
    pop
generateStm (SIfElse exp stm1 stm2) = undefined

generateExp :: Exp -> M ()
generateExp (ETrue) = undefined
generateExp (EFalse) = undefined
generateExp (EInt int) = do
    emitLn $ "ldc " ++ show int
generateExp (EDouble double) = undefined -- Not in lab
generateExp (EId id) = undefined
generateExp (EPostIncr exp) = undefined
generateExp (EPostDecr exp) = undefined
generateExp (EPreIncr exp) = undefined
generateExp (EPreDecr exp) = undefined
generateExp (EPlus exp1 exp2) = do
    generateExp exp1
    generateExp exp2
    emitLn $ "iadd"
generateExp (ETimes exp1 exp2) = do
    generateExp exp1
    generateExp exp2
    emitLn $ "imul" 
generateExp (EDiv exp1 exp2) = do
    generateExp exp1
    generateExp exp2
    emitLn $ "idiv" 
generateExp (EMinus exp1 exp2) = do
    generateExp exp1
    generateExp exp2
    emitLn $ "isub" 
generateExp (ELt exp1 exp2) = do
    generateExp exp1
    generateExp exp2
    emit $ "if_icmplt" -- something more maybe
generateExp (EGt exp1 exp2) = do
    generateExp exp1
    generateExp exp2
    emit $ "if_icmpgt" 
generateExp (ELtEq exp1 exp2) = do
    generateExp exp1
    generateExp exp2
    emit $ "if_icmple" 
generateExp (EGtEq exp1 exp2) = do
    generateExp exp1
    generateExp exp2
    emit $ "if_icmpge" 
generateExp (EEq exp1 exp2) = do
    generateExp exp1
    generateExp exp2
    emit $ "if_acmpeq"
generateExp (ENEq exp1 exp2) = do    
    generateExp exp1
    generateExp exp2
    emit $ "if_acmpne"
generateExp (EAnd exp1 exp2) = undefined
generateExp (EOr exp1 exp2) = undefined
generateExp (EAss exp1 exp2) = undefined
generateExp (EApp (Id fcnid) args) = do 
    mapM generateExp args
    fsig <- lookupFun fcnid
    emit $ "invokestatic runtime/printInt(I)V" -- assuming always calling printInt (Lecture running out of time)
    if (fsOuttyp fsig == Type_void) then
        emit "bipush 0"
    else
        return () 
--emit "return " somewhere