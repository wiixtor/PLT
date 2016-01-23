module Main where 

import AbsCPP
import PrintCPP
import ErrM
import LexCPP
import ParCPP

import Data.Map (Map)
import qualified Data.Map as Map

import Control.Monad
import Control.Monad.State
import Control.Monad.Reader

import System.Environment (getArgs)
import System.Exit
import System.IO
import System.FilePath.Posix
import System.Process

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

push :: Env -> IO Env
push (s,v,l,a,c) = return (s, Map.empty : v,l,a,c)

pop :: Env -> IO Env
pop (s,(v:vs),l,a,c) = return (s,vs,l,a,c)


generateCode :: FilePath -> Program -> IO String
generateCode name (PDefs defs) = do
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
    return $ (boilerplate ++ code env'''')
  where
    halp :: Env -> Def -> IO Env
    halp e (DFun t (Id id) args stms) = do
        (intyps, outtyp) <- lookupFun id e
        out <- help2 t
        intypstring <- help intyps
        env'' <- emitLn (".method public static " ++ id ++ "(" ++  intypstring ++ ")" ++ out) e
        env''' <- emitLn "  .limit locals 1000" env''
        env4 <- emitLn "  .limit stack 1000"  env'''
        env5 <- push env4
        env6 <- generateStms env5 stms
        env7 <- pop env6
        case t of
            Type_void -> do
                env8 <- emitLn "ireturn" env7
                env9 <- emitLn ".end method" env8
                return env9
            _ -> do
                env8 <- emitLn "bipush 0" env7
                env9 <- emitLn "ireturn" env8
                env10 <- emitLn ".end method" env9
                return env10
      where 
    help :: [Type] -> IO String
    help [] = return ""
    help (t:ts) = do
        rest <- help ts
        return $ "I" ++ rest
    help2 :: Type -> IO String
    help2 t = case t of
        Type_int    -> return "I"
        Type_bool   -> return "I"
        Type_void   -> return "V"

    boilerplate :: String
    boilerplate = unlines
      [ ".class public " ++ name
      , ".super java/lang/Object"
      , ""
      , ".method public <init>()V"
      , "  aload_0"
      , "  invokespecial java/lang/Object/<init>()V"
      , "  return"
      , ".end method"
      , ""
      , ".method public static main([Ljava/lang/String;)V"
      , ".limit locals 1"
      , "  invokestatic " ++ name ++ "/main()I"
      , "  pop"
      , "  return"
      , ".end method" ]

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
    env' <- generateExp env exp
    env'' <- emitLn "pop" env'
    return env''
generateStm env (SDecls typ ids) = do
    env' <- foldM 
        declsHelp -- no doubles so size always 1
        env
        ids
    return env'
  where
    declsHelp :: Env -> Id -> IO Env
    declsHelp e (Id id) = updateVar id 1 e
generateStm (s,v,l,a,c) (SInit typ (Id id) exp) = do
    env <- generateExp (s,v,l,a,c) exp
    env' <- emitLn ("istore_" ++ (show a)) env
    env'' <- updateVar id 1 env'
    return env''
generateStm env (SReturn exp) = do
    env' <- generateExp env exp
    env'' <- emitLn "ireturn" env' -- return void atm
    return env''
generateStm env (SWhile exp stm) = do
    (env', start) <- genLabel env
    (env'', end) <- genLabel env'
    env''' <- emitLn (start ++ ":") env''
    env4 <- generateExp env''' exp
    env5 <- emitLn ("ifeq " ++ end) env4
    env6 <- generateStm env5 stm
    env7 <- emitLn ("goto " ++ start) env6
    env8 <- emitLn (end ++ ":") env7
    return env8
generateStm env (SBlock stms) = do
    env' <- push env
    env'' <- generateStms env' stms
    env''' <- pop env''
    return env'''
generateStm env (SIfElse exp stm1 stm2) = do
    (env', els) <- genLabel env
    (env'', end) <- genLabel env'
    env''' <- generateExp env'' exp
    env4 <- emitLn ("ifeq " ++ els) env'''
    env5 <- generateStm env4 stm1
    env6 <- emitLn ("goto " ++ end) env5
    env7 <- emitLn (els ++ ":") env6
    env8 <- generateStm env7 stm2
    env9 <- emitLn (end ++ ":") env8
    return env9


generateExp :: Env -> Exp -> IO Env
generateExp env (ETrue) = do
    env' <- emitLn "ldc 1" env
    return env'
generateExp env (EFalse) = do
    env' <- emitLn "ldc 0" env
    return env'
generateExp env (EInt int) = do
    env' <- emitLn ("ldc " ++ show int) env
    return env'
generateExp env (EDouble double) = undefined -- Not needed in lab
generateExp env (EId (Id adrId)) = do
    p <- lookupVar(adrId) env
    env' <- emitLn ("iload_" ++ (show p)) env
    return env'
generateExp env (EPostIncr exp) = do
    env' <- generateExp env exp
    env'' <- emitLn "dup" env'
    env''' <- emitLn ("ldc " ++ "1") env''
    env4 <- emitLn ("iadd") env'''
    let (EId (Id id)) = exp
    a <- lookupVar id env4
    env5 <- emitLn ("istore_" ++ (show a)) env4
    return env5
generateExp env (EPostDecr exp) = do
    env' <- generateExp env exp
    env'' <- emitLn "dup" env'
    env''' <- emitLn ("ldc " ++ "1") env''
    env4 <- emitLn "isub" env'''
    let (EId (Id id)) = exp
    a <- lookupVar id env4
    env5 <- emitLn ("istore_" ++ (show a)) env4
    return env5
generateExp env (EPreIncr exp) = do 
    env' <- generateExp env exp
    env'' <- emitLn ("ldc " ++ "1") env'
    env''' <- emitLn "iadd" env''
    env4 <- emitLn "dup" env'''
    let (EId (Id id)) = exp
    a <- lookupVar id env4
    env5 <- emitLn ("istore_" ++ (show a)) env4
    return env5
generateExp env (EPreDecr exp) = do
    env' <- generateExp env exp
    env'' <- emitLn ("ldc " ++ "1") env'
    env''' <- emitLn "isub" env''
    env4 <- emitLn "dup" env'''
    let (EId (Id id)) = exp
    a <- lookupVar id env4
    env5 <- emitLn ("istore_" ++ (show a)) env4
    return env5
generateExp env (EPlus exp1 exp2) = do
    env' <- generateExp env exp1
    env'' <- generateExp env' exp2
    env''' <- emitLn "iadd" env'' 
    return env'''
generateExp env (ETimes exp1 exp2) = do
    env' <- generateExp env exp1
    env'' <- generateExp env' exp2
    env''' <- emitLn "imul" env''
    return env'''
generateExp env (EDiv exp1 exp2) = do
    env' <- generateExp env exp1
    env'' <- generateExp env' exp2
    env''' <- emitLn "idiv" env''
    return env'''
generateExp env (EMinus exp1 exp2) = do
    env' <- generateExp env exp1
    env'' <- generateExp env' exp2
    env''' <- emitLn "isub" env'' 
    return env'''
generateExp env (ELt exp1 exp2) = do
    (env', l1) <- genLabel env 
    env'' <- emitLn "bipush 1" env'
    env''' <- generateExp env'' exp1
    env4 <- generateExp env''' exp2
    env5 <- emitLn ("if_icmplt " ++ l1) env4
    env6 <- emitLn "pop" env5
    env7 <- emitLn "bipush 0" env6
    env8 <- emitLn (l1 ++ ":") env7
    return env8
generateExp env (EGt exp1 exp2) = do
    (env', l1) <- genLabel env 
    env'' <- emitLn "bipush 1" env'
    env''' <- generateExp env'' exp1
    env4 <- generateExp env''' exp2
    env5 <- emitLn ("if_icmpgt " ++ l1) env4
    env6 <- emitLn "pop" env5
    env7 <- emitLn "bipush 0" env6
    env8 <- emitLn (l1 ++ ":") env7
    return env8
generateExp env (ELtEq exp1 exp2) = do
    (env', l1) <- genLabel env 
    env'' <- emitLn "bipush 1" env'
    env''' <- generateExp env'' exp1
    env4 <- generateExp env''' exp2
    env5 <- emitLn ("if_icmple " ++ l1) env4
    env6 <- emitLn "pop" env5
    env7 <- emitLn "bipush 0" env6
    env8 <- emitLn (l1 ++ ":") env7
    return env8
generateExp env (EGtEq exp1 exp2) = do
    (env', l1) <- genLabel env 
    env'' <- emitLn "bipush 1" env'
    env''' <- generateExp env'' exp1
    env4 <- generateExp env''' exp2
    env5 <- emitLn ("if_icmpge " ++ l1) env4
    env6 <- emitLn "pop" env5
    env7 <- emitLn "bipush 0" env6
    env8 <- emitLn (l1 ++ ":") env7
    return env8
generateExp env (EEq exp1 exp2) = do
    (env', l1) <- genLabel env 
    env'' <- emitLn "bipush 1" env'
    env''' <- generateExp env'' exp1
    env4 <- generateExp env''' exp2
    env5 <- emitLn ("if_acmpeq " ++ l1) env4
    env6 <- emitLn "pop" env5
    env7 <- emitLn "bipush 0" env6
    env8 <- emitLn (l1 ++ ":") env7
    return env8
generateExp env (ENEq exp1 exp2) = do
    (env', l1) <- genLabel env 
    env'' <- emitLn "bipush 1" env'
    env''' <- generateExp env'' exp1
    env4 <- generateExp env''' exp2
    env5 <- emitLn ("if_acmpne " ++ l1) env4
    env6 <- emitLn "pop" env5
    env7 <- emitLn "bipush 0" env6
    env8 <- emitLn (l1 ++ ":") env7
    return env8
generateExp env (EAnd exp1 exp2) = do
    env' <- generateExp env exp1
    env'' <- generateExp env' exp2
    env''' <- emitLn "iand" env''

    {-(env', l1) <- genLabel env
    (env'', l2) <- genLabel env'
    env''' <- emitLn "bipush 1" env''
    env4 <- generateExp env''' exp1
    env5 <- emitLn ("iand " ++ l1) env4
    env6 <- emitLn "bipush 1" env5
    env7 <- generateExp env6 exp2
    env8 <- emitLn ("iand " ++ l2) env7
    env9 <- emitLn "bipush 1" env8
    env10 <- emitLn ("goto " ++ l2) env9
    env11 <- emitLn (l1 ++ ":") env10
    env12 <- emitLn "bipush 0" env11
    env13 <- emitLn (l2 ++ ":") env12
    return env13 -}
generateExp env (EOr exp1 exp2) = do  
    env' <- generateExp env exp1
    env'' <- generateExp env' exp2
    env''' <- emitLn "ior" env''

    {- (env', l1) <- genLabel env
    (env'', l2) <- genLabel env'
    env''' <- emitLn "bipush 1" env''
    env4 <- generateExp env''' exp1
    env5 <- emitLn ("ior " ++ l1) env4
    env6 <- emitLn "bipush 1" env5
    env7 <- generateExp env6 exp2
    env8 <- emitLn ("ior " ++ l2) env7
    env9 <- emitLn "bipush 0" env8
    env10 <- emitLn ("goto " ++ l2) env9
    env11 <- emitLn (l1 ++ ":") env10
    env12 <- emitLn "bipush 1" env11
    env13 <- emitLn (l2 ++ ":") env12
    return env13 -}
generateExp env (EAss exp1 exp2) = do
    env' <- generateExp env exp1
    env'' <- generateExp env' exp2
    let (EId (Id id)) = exp1
    a <- lookupVar id env''
    env''' <- emitLn ("dup") env''
    env'''' <- emitLn ("istore_" ++ (show a)) env'''
    return env''''
generateExp env (EApp (Id "printInt") args) = do
    env' <- foldM
        generateExp 
        env
        args
    env'' <- emitLn "invokestatic Runtime/printInt(I)V" env'
    env''' <- emitLn "bipush 0" env''
    return env'''
generateExp env (EApp (Id "readInt") args) = do
    env' <- emitLn "invokestatic Runtime/readInt()I" env
    return env'
generateExp env (EApp (Id fcnid) args) = do
    env' <- foldM
        generateExp 
        env
        args

    (intyps, outtyp) <- lookupFun fcnid env'
    intypstring <- help intyps
    out <- help2 outtyp
    env'' <- emitLn ("invokestatic Runtime/" ++ fcnid ++ "(" ++  intypstring ++ ")" ++ out) env'
    return env''

  where 
    help :: [Type] -> IO String
    help [] = return ""
    help (t:ts) = do
        rest <- help ts
        return $ "I" ++ rest
    help2 :: Type -> IO String
    help2 t = case t of
        Type_int    -> return "I"
        Type_bool   -> return "I"
        Type_void   -> return "V"

-- driver
check :: FilePath -> String -> IO ()
check file s = case pProgram (myLexer s) of
  Bad err  -> do
    putStrLn "SYNTAX ERROR"
    putStrLn err
    exitFailure
  Ok tree -> do
    case typecheck tree of
      Bad err -> do
        putStrLn "TYPE ERROR"
        putStrLn err
        exitFailure
      Ok () -> do
        -- hPutStrLn stderr $ show annTree
        let name   = takeBaseName file
        jasmin <- generateCode name tree
        let dir    = takeDirectory file
        let jfile  = replaceExtension file "j"
        writeFile jfile jasmin

        -- Convert jasmin to JVM
        -- Pipe stdout to stderr, otherwise the "Generated xxx.class" upsets test suite
        pHandle <- runProcess
                   "java" -- executable
                   ["-jar", "jasmin.jar", "-d", dir, jfile] -- arguments
                   Nothing -- working directory
                   Nothing -- environment
                   Nothing -- input handle
                   (Just stderr) -- output handle
                   Nothing -- error handle
        exitCode <- waitForProcess pHandle
        case exitCode of
          ExitSuccess -> do
            hPutStrLn stderr "OK"
            exitSuccess
          ExitFailure i -> do
            putStrLn "JASMIN CONVERSION ERROR"
            exitWith exitCode

main :: IO ()
main = do
  args <- getArgs
  case args of
    [file] -> readFile file >>= check file
    _      -> do
      putStrLn "Usage: lab3 <SourceFile>"
      exitFailure