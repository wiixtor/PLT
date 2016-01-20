module Main where 

import AbsCPP
import PrintCPP
import ErrM

import Control.Monad

import Data.Map (Map)
import qualified Data.Map as Map

import Control.Monad.State

import System.Environment (getArgs)
import System.Exit (exitFailure)

import LexCPP
import ParCPP

import TypeChecker (typecheck)

type Env = (EnvSignature, EnvVariables, LabelCounter, EnvAddress, Code)
type EnvSignature = Map String FunSig
type EnvVariables = [Map String Address]
type LabelCounter = Int
type EnvAddress = Int
type Code = String
type Address = Int
type FunSig = ([Type], Type) -- ([intyps],outtyp)

genLabel :: Env -> IO (Env, String)
genLabel (s,v,l,a,c) = return ((s,v,l+1,a,c), ("label" ++ (show l)))

updateVar :: String -> Int -> Env -> IO Env
updateVar id size (s,(v:vs),l,a,c) = return (s, Map.insert id a v : vs, l, a+size, c)

updateFun ::  Env -> Def -> IO Env
updateFun (s,v,l,a,c) (DFun t (Id id) args _) = return (Map.insert id (gettypes args,t) s,v,l,a,c)
  where
    gettypes :: [Arg] -> [Type]
    gettypes = map (\(ADecl t _) -> t)

lookupFun :: String -> Env -> IO FunSig
lookupFun id (s,v,l,a,c) = return $ s Map.! id

lookupVar :: String -> Env -> IO Address
lookupVar id (s,v,l,a,c) = return $ help v id
 where 
    help :: [Map String Address] -> String -> Address
    help [] id = error "no variable found"
    help (v:vs) id =
        case (Map.lookup id v) of
            Nothing -> help vs id
            Just x -> x

emptyEnv :: IO Env 
emptyEnv = return (Map.empty, [Map.empty], 0, 0, "")

emitLn :: String -> Env -> IO Env
emitLn line (s,v,l,a,c) = return (s,v,l,a, c ++ line ++ "\n")

emit :: String -> Env -> IO Env
emit line (s,v,l,a,c) = return (s,v,l,a, c ++ line)

push :: Env -> IO Env
push (s,v,l,a,c) = return (s, Map.empty : v,l,a,c)

pop :: Env -> IO Env
pop (s,(v:vs),l,a,c) = return (s,vs,l,a,c)


generateCode :: Program -> IO String
generateCode (PDefs defs) = do
    env <- emptyEnv
    env' <- updateFun env (DFun Type_void (Id "printInt") [ADecl Type_int (Id "x")] [])
    env'' <- updateFun env (DFun Type_int (Id "readInt") [] [])
        -- skipping adding user defined functions to signature
    env''' <- foldM
        updateFun
        env''
        defs
    env'''' <- foldM
        halp
        env'''
        defs
    return $ code env''''
  where
    halp :: Env -> Def -> IO Env
    halp e (DFun _ _ _ stms) = generateStms e stms

code :: Env -> Code
code (s,v,l,a,c) = c

generateStms :: Env -> [Stm] -> IO Env
generateStms env stms = do
    env' <- foldM 
        generateStm 
        env 
        stms
    return env'

generateStm :: Env -> Stm -> IO Env
generateStm env (SExp exp) = do
    generateExp env exp
    emitLn "pop" env
    return env
generateStm env (SDecls typ ids) = do
    mapM (\(Id id) -> do
        updateVar id 1 env) -- no doubles so size always 1
        ids
    return env
generateStm (s,v,l,a,c) (SInit typ (Id id) exp) = do
    generateExp (s,v,l,a,c) exp
    emitLn $ "istore " ++ (show a) $ (s,v,l,a,c)
    updateVar id 1 (s,v,l,a,c)
    return (s,v,l,a,c)
generateStm env (SReturn exp) = do
    generateExp env exp
    emitLn "return" env -- return void atm
    return env
generateStm env (SWhile exp stm) = do
    start <- genLabel env
    end <- genLabel env
    emitLn (start ++ ":") env
    generateExp env exp
    emitLn ("ifeq " ++ end) env
    generateStm env stm
    emitLn ("goto " ++ start) env
    emitLn (end ++ ":") env
    return env
generateStm env (SBlock stms) = do
    push env
    generateStms env stms
    pop env
    return env
generateStm env (SIfElse exp stm1 stm2) = do
    els <- genLabel env
    end <- genLabel env
    generateExp env exp
    emitLn ("ifeq " ++ els) env
    generateStm env stm1
    emitLn ("goto " ++ end) env
    emitLn (els ++ ":") env
    generateStm env stm2
    emitLn (end ++ ":") env

generateExp :: Env -> Exp -> IO Env
generateExp env (ETrue) = do
    emitLn "ldc 1" env
    return env
generateExp env (EFalse) = do
    emitLn "ldc 0" env
    return env
generateExp env (EInt int) = do
    emitLn ("ldc " ++ show int) env
    return env
generateExp env (EDouble double) = undefined -- Not needed in lab
generateExp env (EId (Id adrId)) = do
    p <- lookupVar(adrId) env
    emitLn ("iload " ++ (show p)) env
    return env
generateExp env (EPostIncr exp) = do
    generateExp env exp
    emitLn "dup" env
    emitLn ("ldc " ++ "1") env
    emitLn ("iadd") env
    let (EId (Id id)) = exp
    a <- lookupVar id env
    emitLn ("istore " ++ (show a)) env
    return env
generateExp env (EPostDecr exp) = do
    generateExp env exp
    emitLn "dup" env
    emitLn ("ldc " ++ "1") env
    emitLn "isub" env
    let (EId (Id id)) = exp
    a <- lookupVar id env
    emitLn ("istore " ++ (show a)) env
    return env
generateExp env (EPreIncr exp) = do 
    generateExp env exp
    emitLn ("ldc " ++ "1") env
    emitLn "iadd" env
    emitLn "dup" env
    let (EId (Id id)) = exp
    a <- lookupVar id env
    emitLn ("istore " ++ (show a)) env
    return env
generateExp env (EPreDecr exp) = do
    generateExp env exp
    emitLn ("ldc " ++ "1") env
    emitLn "isub" env
    emitLn "dup" env
    let (EId (Id id)) = exp
    a <- lookupVar id env
    emitLn ("istore " ++ (show a)) env
    return env
generateExp env (EPlus exp1 exp2) = do
    generateExp env exp1
    generateExp env exp2
    emitLn "iadd" env 
    return env
generateExp env (ETimes exp1 exp2) = do
    generateExp env exp1
    generateExp env exp2
    emitLn "imul" env
    return env
generateExp env (EDiv exp1 exp2) = do
    generateExp env exp1
    generateExp env exp2
    emitLn "idiv" env
    return env
generateExp env (EMinus exp1 exp2) = do
    generateExp env exp1
    generateExp env exp2
    emitLn "isub" env 
    return env
generateExp env (ELt exp1 exp2) = do
    generateExp env exp1
    generateExp env exp2
    emit "if_icmplt" env -- something more maybe
    return env
generateExp env (EGt exp1 exp2) = do
    generateExp env exp1
    generateExp env exp2
    emit "if_icmpgt" env
    return env 
generateExp env (ELtEq exp1 exp2) = do
    generateExp env exp1
    generateExp env exp2
    emit "if_icmple" env 
    return env 
generateExp env (EGtEq exp1 exp2) = do
    generateExp env exp1
    generateExp env exp2
    emit "if_icmpge" env
    return env
generateExp env (EEq exp1 exp2) = do
    generateExp env exp1
    generateExp env exp2
    emit "if_acmpeq" env
    return env
generateExp env (ENEq exp1 exp2) = do    
    generateExp env exp1
    generateExp env exp2
    emit "if_acmpne" env
    return env
generateExp env (EAnd exp1 exp2) = do
    generateExp env exp1
    generateExp env exp2
    emit "iand" env
    return env 
generateExp env (EOr exp1 exp2) = do    
    generateExp env exp1
    generateExp env exp2
    emit "ior" env
    return env
generateExp env (EAss exp1 exp2) = do
    generateExp env exp1
    generateExp env exp2
    let (EId (Id id)) = exp1
    a <- lookupVar id env
    emitLn ("istore " ++ (show a)) env
    return env
generateExp env (EApp (Id fcnid) args) = do 
    mapM generateExp args env
    (fsig) <- lookupFun fcnid env
    if (null $ fst fsig) then
        emit "invokestatic runtime/readInt()I" env
    else 
        emit "invokestatic runtime/printInt(I)V" env
    if (snd fsig == Type_void) then
        emit "bipush 0" env
    else
        return env




-- driver

check :: String -> IO ()
check s = do
  case pProgram (myLexer s) of
    Bad err  -> do
      putStrLn "SYNTAX ERROR"
      putStrLn err
      exitFailure
    Ok  tree -> do
      case typecheck tree of
        Bad err -> do
          putStrLn "TYPE ERROR"
          putStrLn err
          exitFailure
        Ok _ -> generateCode tree

main :: IO ()
main = do
  args <- getArgs
  case args of
    [file] -> readFile file >>= check
    _      -> do
      putStrLn "Usage: lab2 <SourceFile>"
      exitFailure