module Test.Lambda where

import qualified Data.Set as Set
import Lambda
import Constants
import Test.Tasty
import Test.Tasty.HUnit
import Data.Function

unit_show :: IO ()
unit_show = do
  show x @?= "x"
  show xy @?= "x y"
  show lxy @?= "λx.y"
  show true @?= "λx.λy.x"
  show and' @?= "λp.λq.p q p"
  show two @?= "λf.λx.f (f x)"
  show mult' @?= "λm.λn.m ((λm.λn.λf.λx.m f (n f x)) n) (λf.λx.x)"

unit_freeVariables :: IO ()
unit_freeVariables = do
  freeVariables x @?= Set.fromList ["x"]
  freeVariables xy @?= Set.fromList ["x", "y"]
  freeVariables lxy @?= Set.fromList ["y"]
  freeVariables true @?= Set.empty
  freeVariables and' @?= Set.empty
  freeVariables two @?= Set.empty
  freeVariables mult' @?= Set.empty

unit_fresh :: IO ()
unit_fresh = do
  take 33 (candidates :: [String]) @?= ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "ba", "bb", "bc", "bd", "be", "bf", "bg"]

db1 :: Lambda
db1 = Abs "x" (Abs "y" (Var "x"))

db2 :: Lambda
db2 = Abs "x" (Abs "y" (Abs "z" (App (App (Var "x") (Var "z")) (App (Var "y") (Var "z")))))

db3 :: Lambda
db3 = Abs "z" (App (Abs "y" (App (Var "y") (Abs "x" (Var "x")))) (Abs "x" (App (Var "z") (Var "x"))))

db1' :: Lambda
db1' = Abs "y" (Abs "z" (Var "y"))

db1'' :: Lambda
db1'' = Abs "y" (Abs "z" (Var "z"))

db2' :: Lambda
db2' = Abs "a" (Abs "b" (Abs "c" (App (App (Var "a") (Var "c")) (App (Var "b") (Var "c")))))

db4 :: Lambda
db4 = Abs "x" (Var "y")

unit_toDeBruijn :: IO ()
unit_toDeBruijn = do
  toDeBruijn db1 @?= AbsDB (AbsDB (VarDB 2))
  toDeBruijn db1' @?= AbsDB (AbsDB (VarDB 2))
  toDeBruijn db1'' @?= AbsDB (AbsDB (VarDB 1))
  toDeBruijn db2 @?= AbsDB (AbsDB (AbsDB (AppDB (AppDB (VarDB 3) (VarDB 1)) (AppDB (VarDB 2) (VarDB 1))))) -- "λ1. λ2. λ3. 3 1 (2 1)"
  toDeBruijn db2' @?= AbsDB (AbsDB (AbsDB (AppDB (AppDB (VarDB 3) (VarDB 1)) (AppDB (VarDB 2) (VarDB 1))))) -- "λ1. λ2. λ3. 3 1 (2 1)"
  toDeBruijn db3 @?= AbsDB (AppDB (AbsDB (AppDB (VarDB 1) (AbsDB (VarDB 1)))) (AbsDB (AppDB (VarDB 2) (VarDB 1)))) -- "λ (λ 1 (λ 1)) (λ 2 1)"
  toDeBruijn db4 @?= AbsDB (VarDB 2)

back1 :: Lambda
back1 = fromDeBruijn $ toDeBruijn db1
back2 :: Lambda
back2 = fromDeBruijn $ toDeBruijn db2
back3 :: Lambda
back3 = fromDeBruijn $ toDeBruijn db3
back4 :: Lambda
back4 = fromDeBruijn $ toDeBruijn db4

unit_fromDeBruijn :: IO ()
unit_fromDeBruijn = do
  toDeBruijn back1 @?= toDeBruijn db1
  toDeBruijn back2 @?= toDeBruijn db2
  toDeBruijn back3 @?= toDeBruijn db3
  toDeBruijn back4 @?= toDeBruijn db4

unit_alpha :: IO ()
unit_alpha = do
  alphaEq db1 db1' @?= True
  alphaEq db1 db1'' @?= False
  alphaEq db1 db2' @?= False
  alphaEq db2 db2' @?= True