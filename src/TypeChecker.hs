module TypeChecker where

import System.Environment
import Data.List
import Data.Set (Set)
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Grammar
import Unparsing

--
-- lookup in map is O(logn)
--
type Map = Map.Map
type FunEnv = (Identifier, ([BindingType], CaseExpression))
type FunEnvMap = Map Identifier ([BindingType], CaseExpression)
type BindEnv = (Identifier, Constant)
type BindEnvMap = Map Identifier Constant

allTysExist' :: [BindingType] -> BindEnvMap -> Constant
allTysExist' [] _ = BoolLit True
allTysExist' [(BType _ _ TUniverse)] _ = BoolLit True
allTysExist' [(BType _ _ (TCustom tc))] bEnv =
  case (Map.lookup tc bEnv) of
    Just v -> BoolLit True
    _ -> Epsilon ("Type " ++ (unparseType' (TCustom tc)) ++ " could not be found")
allTysExist' [(BType _ _ (TGroup group))] bEnv =
  allTysExist' [(BType [""] ElementOf group)] bEnv
allTysExist' [(BType _ _ (TBinOp _ t1 t2))] bEnv =
  case (allTysExist' [(BType [""] ElementOf  t1)] bEnv, allTysExist' [(BType [""] ElementOf t2)] bEnv) of
    (BoolLit True, BoolLit True) -> BoolLit True
    (Epsilon s, BoolLit True) -> Epsilon s
    (BoolLit True, Epsilon s) -> Epsilon s
    -- TODO: the line above is wrong, fix later
    _ -> BoolLit True
allTysExist' (x:xs) bEnv =
  case (allTysExist' [x] bEnv) of
    BoolLit True -> allTysExist' xs bEnv
    Epsilon s -> Epsilon s

{-
 - Type rules are as described on TYPE_RULES.md file
 -}

cartProd xs ys = [(x,y) | x <- xs, y <- ys]

-- TODO: Implement tuples
extractConsts' :: [Expression] -> [Constant] -> Maybe [Constant]
extractConsts' [] acc = Just acc
extractConsts' ((EConst c):xs) acc = extractConsts' xs (acc ++ [c])
extractConsts' _ _ = Nothing

matchType' :: Relationship -> Type -> Maybe (Set Constant) -> Constant -> Bool
matchType' ElementOf TUniverse _ _ = True
matchType' SubsetOf TUniverse _ _ = True
matchType' _ _ _ _ = True
-- TODO: implement type matching correctly
{-
matchType' ElementOf (TCustom ty) (Just s) c =
  case (Set.toList s) of
    [(SetLit s')] ->
      case (extractConsts' s' []) of
        Just consts -> matchType' ElementOf (TCustom ty) (Just (Set.fromList consts)) c
        _ -> False
    _ -> Set.member c s
-- TODO check if tuples are needed
matchType' SubsetOf (TCustom ty) (Just s) c =
  case c of
    SetLit sub_s ->
      case (extractConsts' sub_s []) of
        Just consts -> Set.isSubsetOf (Set.fromList consts) s
        _ -> False
    _ -> False
matchType' _ _ _ _ = True
-}
