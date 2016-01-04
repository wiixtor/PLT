module CodeGenerator where 

import AbsCPP
import PrintCPP
import ErrM

import Control.Monad

import Data.Map (Map)
import qualified Data.Map as Map

import Control.Monad.State

data Address = Address
    {
        address :: String
    }
    deriving Show

data FunSig = FunSig 
    {
        fsIntyps :: [Type],
        fsOuttyp :: Type
    }

data Env = Env 
    {
        envSignature :: Map String FunSig,
        envVariables :: [Map String Address],
        labelCounter :: Int
    }


--state transformer monad
type M a = StateT Env IO a

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

genLabel :: M String
genLabel = do
    label <- gets labelCounter
    modify (\env -> env {labelCounter = (labelCounter env) + 1})
    return $ "label" ++ (show label)


updateFun :: String -> FunSig -> M ()
updateFun id sig = do
    env <- get 
    put $ env { envSignature = Map.insert id sig (envSignature env) }

lookupFun :: String -> M FunSig
lookupFun id = do
    env <- get
    return $ envSignature env Map.! id 

lookupVar :: String -> M Address
lookupVar id = do
    env <- get
    return $ (head $ envVariables env) Map.! id

emptyEnv :: Env 
emptyEnv =
    Env 
    {
        envSignature = Map.empty,
        envVariables = [Map.empty],
        labelCounter = 0
    }

emitLn :: String -> M ()
emitLn line = lift $ putStrLn line

emit :: String -> M ()
emit line = 
    lift $ putStr line

push :: M ()
push = do
    env <- get
    put $ env { envVariables = (Map.empty : (envVariables env)) }
    return ()

pop :: M ()
pop = do
    env <- get
    put $ env {envVariables = (tail $ envVariables env)}
  --  Map.deleteAt (Map.size (envVariables env)) (envVariables env)
    return ()


generateCode :: Program -> IO()
generateCode (PDefs defs) = do
    evalStateT f emptyEnv -- Monad function
    return ()
    where 
        f = do
            updateFun "printInt" (FunSig {fsIntyps = [Type_int], fsOuttyp = Type_void})
            -- skipping adding user defined functions to signature
            mapM (\(DFun outtyp id args stms) -> do 
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
generateStm (SInit typ (Id id) exp) = do
    generateExp exp
    if (typ == Type_int) then do
        emitLn $ "istore " ++ id
    else do
        emitLn $ "astore " ++ id
    -- emitLn "pop"
generateStm (SReturn exp) = do
    generateExp exp
    emitLn "return" -- return void atm
generateStm (SWhile exp stm) = do
    start <- genLabel
    end <- genLabel
    emitLn $ start ++ ":"
    generateExp exp
    emitLn $ "ifeq" ++ end
    generateStm stm
    emitLn $ "goto" ++ start
    emitLn $ end ++ ":"
generateStm (SBlock stms) = do
    push
    generateStms stms
    pop
    return ()
generateStm (SIfElse exp stm1 stm2) = do
    els <- genLabel
    end <- genLabel
    generateExp exp
    emitLn $ "ifeq" ++ els
    generateStm stm1
    emitLn $ "goto" ++ end
    emitLn $ els ++ ":"
    generateStm stm2
    emitLn $ end ++ ":"

generateExp :: Exp -> M ()
generateExp (ETrue) = undefined
generateExp (EFalse) = undefined
generateExp (EInt int) = do
    emitLn $ "ldc " ++ show int
generateExp (EDouble double) = undefined -- Not needed in lab
generateExp (EId (Id adrId)) = do
    p <- lookupVar(adrId)
    emitLn $ "iload" ++ (show p)
generateExp (EPostIncr exp) = undefined
generateExp (EPostDecr exp) = undefined
generateExp (EPreIncr exp) = do 
    generateExp exp
    emitLn $ "ldc" ++ "1"
    emitLn $ "iadd"
    emitLn $ "dup"
    emitLn $ "istore" -- the address
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
    if (null fsIntyps fsig) 
        emit $ "invokestatic runtime/readInt()V"
    else 
        emit $ "invokestatic runtime/printInt(I)V"
    if (fsOuttyp fsig == Type_void) then
        emit "bipush 0"
    else
        return () 