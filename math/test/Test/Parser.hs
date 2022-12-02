module Test.Parser where

import Test.Tasty.HUnit
import Test.Tasty

import Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import Test.Tasty.Hedgehog

import Control.Exception (assert)
import Parser
import Expr

unit_string_parser = do
    runParser (string "abc") "abcde" @?= Just ("de", "abc")
    runParser (string "abc") "abbde" @?= Nothing
    runParser (string "sin") "sin(0)" @?= Just ("(0)", "sin")


unit_number_parser = do
    runParser number "12345 ABCDE" @?= Just (" ABCDE", 12345)
    runParser number "-12" @?= Just ("", -12)
    runParser number "-12.001" @?= Just ("", -12.001)
    runParser number "123.123" @?= Just ("", 123.123)
    runParser number "123.000123" @?= Just ("", 123.000123)
    runParser number "0.0001" @?= Just ("", 0.0001)


unit_expr_parser = do
    let x = Expr.Var "x"
    let y = Expr.Var "y"
    let z = Expr.Var "z"
    let minus = BinOp Minus
    let plus = BinOp Plus
    let mult = BinOp Mult
    let div = BinOp Div
    let pow = BinOp Pow


    runParser exprParser "-3.14" @?= Just ("", Number (-3.14))
    runParser exprParser "x" @?= Just ("", x)
    runParser exprParser "-x" @?= Just ("", UnaryOp UnaryMinus x)
    runParser exprParser "x-y+z-x+y-z" @?= Just ("", x `minus` y `plus` z `minus` x `plus` y `minus` z)
    runParser exprParser "x*y/z*x" @?= Just ("", x `mult` y `div` z `mult` x)
    runParser exprParser "1-variable" @?= Just ("", minus (Number 1) (Expr.Var "variable"))
    runParser exprParser "x*y+x/y" @?= Just ("", plus (mult x y) (div x y))
    runParser exprParser "sin(1-x)" @?= Just ("", UnaryOp Sin $ minus (Number 1) x)
    runParser exprParser "cos(x^abs(y))" @?= Just ("", UnaryOp Cos $ BinOp Pow x $ UnaryOp Abs y)
    runParser exprParser "x+z*(-y)^((sin(z)))" @?=
        Just ("", plus x $ mult z $ BinOp Pow (UnaryOp UnaryMinus y) $ UnaryOp Sin z)
    runParser exprParser "sin(x^cos(y))*x" @?= Just("", UnaryOp Sin (x `pow` UnaryOp Cos y) `mult` x)



props :: [TestTree]
props = 
  [ testCase "string parser" unit_string_parser
  , testCase "number parser" unit_number_parser
  , testCase "expr parser" unit_expr_parser
  ]