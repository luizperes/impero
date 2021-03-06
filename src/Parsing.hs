module Parsing where

import System.Environment
import Control.Monad
import Control.Applicative hiding ((<|>))
import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr
import Text.ParserCombinators.Parsec.Language
import qualified Text.ParserCombinators.Parsec.Token as Token
import Grammar

languageDef =
  emptyDef { Token.commentStart    = "/'"
           , Token.commentEnd      = "'/"
           , Token.commentLine     = "#"
           , Token.identStart      =   letter
                                   <|> start_symbol
           , Token.identLetter     =   alphaNum
                                   <|> start_symbol
                                   <|> other_symbol
           , Token.reservedNames   = [ "let"
                                     , "do"
                                     , "subset"
                                     , "of"
                                     , "in"
                                     , "otherwise"
                                     , "union"
                                     , "intersection"
                                     , "Universe"
                                     , "any"
                                     ]
           , Token.reservedOpNames = [ "+", "-", "*", "/", "%", "^"
                                     , ".."
                                     , "<", ">", ">=", "<=", "=>"
                                     , "=", "~"
                                     , "∈", "⊆", "∘"
                                     , "->", "\\"
                                     , "∪", "∩", "×", "→"
                                     , "*'"
                                     ]
           , caseSensitive         = True
           }

start_symbol = oneOf "!@$_?|"
-- TODO: study what symbols will be valid as identifiers
-- other_symbol = oneOf "+-*/%^<>~"
other_symbol = oneOf ""

lexer = Token.makeTokenParser languageDef

identifier = Token.identifier lexer -- parses an identifier
reserved   = Token.reserved   lexer -- parses a reserved name
reservedOp = Token.reservedOp lexer -- parses an operator
parens     = Token.parens     lexer -- parses surrounding parenthesis:
                                    -- parens p
                                    -- takes care of the parenthesis and
                                    -- uses p to parse what's inside them
integer    = Token.integer    lexer -- parses an integer number
natural    = Token.natural    lexer -- parses a natural number
float      = Token.float      lexer -- parses a floating number
whiteSpace = Token.whiteSpace lexer -- parses whitespace
symbol     = Token.symbol     lexer -- parses symbols

commaSep p  = p `sepBy`  (symbol ",")
commaSep1 p = p `sepBy1` (symbol ",")
braces p    = between (symbol "{") (symbol "}") p

parse' :: Parser [BeginStmt]
parse' =  whiteSpace
       >> many1 statement'

letStmt' :: Parser BeginStmt
letStmt' = do
  reserved "let"
  binds <- (many1 (try binding' <|> bindingExpr'))
  return $ LetStmt binds

doStmt' :: Parser BeginStmt
doStmt' = do
  reserved "do"
  fcall <- functionCall'
  return $ DoStmt fcall

functionCall' :: Parser FunctionCall
functionCall' =   singleFunctionCall'
              <|> nestedFunctionCall'

singleFunctionCall' :: Parser FunctionCall
singleFunctionCall' = do
  c <- constant'
  return $ FCSingle c

bindingFunctionCall' :: Parser BindingName
bindingFunctionCall' = do
  bindName <- bindingName'
  (symbol "." <|> symbol "∘")
  return $ bindName

nestedFunctionCall' :: Parser FunctionCall
nestedFunctionCall' = do
  bindName <- bindingFunctionCall'
  result <- (singleFunctionCall' <|> nestedFunctionCall')
  return $ FCNested bindName result

constant' :: Parser Constant
constant' = try
              doubleLit'
          <|> naturalLit'
          <|> intLit'
          <|> char'
          <|> tuple'
          <|> set'
          <|> any'

any' :: Parser Constant
any' = do
  reserved "any"
  return $ AnyLit

set' :: Parser Constant
set' = do
  list <- braces (commaSep expr')
  return $ SetLit list

tuple' :: Parser Constant
tuple' = do
  list <- parens min1Expr'
  return $ TupleLit list

min1Expr' :: Parser [Expression]
min1Expr' = do
  expr <- expr'
  symbol ","
  exprs <- commaSep expr'
  return $ [expr] ++ exprs

doubleLit' :: Parser Constant
doubleLit' = do
  f <- float
  return $ NumLit f

naturalLit' :: Parser Constant
naturalLit' = (natural >>= (\n -> return $ NumLit (fromIntegral n)))

intLit' :: Parser Constant
intLit' = (integer >>= (\i -> return $ NumLit (fromIntegral i)))

charFromEscape :: Char -> Char
charFromEscape '0' = '\0'
charFromEscape 'b' = '\b'
charFromEscape 'f' = '\f'
charFromEscape 'n' = '\n'
charFromEscape 'r' = '\r'
charFromEscape 't' = '\t'
charFromEscape 'v' = '\v'

escapeChar' :: Char -> Bool
escapeChar' c =
  case elem c "0bfnrtv" of
    True -> True
    _ -> False

validChar' :: Parser Char
validChar' = try (char '\\' >> (satisfy escapeChar') >>=
                  (\c -> return $ charFromEscape c))
           <|> (anyChar >>= (\c -> return $ c))

char' :: Parser Constant
char' = do
  symbol "'"
  c <- validChar'
  symbol "'"
  return $ CharLit c

statement' :: Parser BeginStmt
statement' =   letStmt'
           <|> doStmt'

listExpr' :: Parser [Expression]
listExpr' = do
  expr <- expr'
  exprs <- option [] (symbol "," >> (commaSep expr'))
  return $ [expr] ++ exprs

otherwise' :: Parser [Expression]
otherwise' = do
  reserved "otherwise"
  return $ [EConst (BoolLit True)]

case' :: Parser (Expression, [Expression])
case' = do
  symbol "["
  expr  <- expr'
  exprs <- (otherwise' <|> listExpr')
  symbol "]"
  return $ (expr, exprs)

multiCase' :: Parser CaseExpression
multiCase' = do
  exprs <- many1 case'
  return $ CECase exprs

listCase' :: Parser CaseExpression
listCase' = do
  exprs <- listExpr'
  return $ CEList exprs

binding' :: Parser Binding
binding' = do
  bindName <- bindingName'
  symbol "=>"
  pattern <- patternListStmt'
  symbol ":"
  cases <- (multiCase' <|> listCase')
  return $ BBind bindName pattern cases

bindingExpr' :: Parser Binding
bindingExpr' = do
  bindName <- bindingName'
  symbol "="
  expr <- expr'
  return $ BExpr bindName expr

bindingName' :: Parser BindingName
bindingName' = do
  id <- identifier
  return $ id

expr' :: Parser Expression
expr' = buildExpressionParser operators' term'

funcCallExpr' = (reservedOp "." <|> reservedOp "∘")

inOp' = (reserved "in" <|> reservedOp "∈")

subsetOp' =   ((reserved "subset" >> reserved "of")
          <|> reservedOp "⊆")

prefix' p = Prefix . chainl1 p $ return (.)
operators' = [ [prefix' $ (char '~'       >> return (EUnOp  Negation))     ]
             , [Infix   (funcCallExpr'    >> return (EBinOp FCall)) AssocRight]
             , [prefix' $ (char '-'       >> return (EUnOp  Negative))     ]
             , [Infix   (reservedOp "^"   >> return (EBinOp Exp)) AssocRight]
             , [Infix   (reservedOp "*"   >> return (EBinOp Mul)) AssocLeft,
                Infix   (reservedOp "%"   >> return (EBinOp Mod)) AssocLeft,
                Infix   (reservedOp "/"   >> return (EBinOp Div)) AssocLeft]
             , [Infix   (reservedOp ".."  >> return (EBinOp Range)) AssocNone]
             , [Infix   (reservedOp "+"   >> return (EBinOp Add)) AssocLeft,
                Infix   (reservedOp "-"   >> return (EBinOp Sub)) AssocLeft]
             , [Infix   (reservedOp ">"   >> return (EBinOp Gt )) AssocNone,
                Infix   (reservedOp ">="  >> return (EBinOp GtE)) AssocNone,
                Infix   (reservedOp "<"   >> return (EBinOp Lt )) AssocNone,
                Infix   (reservedOp "<="  >> return (EBinOp LtE)) AssocNone]
             , [Infix   (reservedOp "="   >> return (EBinOp Eq )) AssocNone,
                Infix   (reservedOp "~"   >> return (EBinOp NEq)) AssocNone]
             , [Infix   (inOp'            >> return (EBinOp In )) AssocNone,
                Infix  (subsetOp'        >> return (EBinOp Subset)) AssocNone]
             ]

term' :: Parser Expression
term' =   try (liftM EConst constant')
      <|> liftM EBind bindingName'
      <|> parens expr'

patternListStmt' :: Parser PatternStmt
patternListStmt' = do
  patterns <- commaSep patternStmt'
  return $ PatternListStmt patterns

patternStmt' :: Parser PatternStmt
patternStmt' = simpleStmt'

simpleStmt' :: Parser PatternStmt
simpleStmt' = do
  bindType <- bindingType'
  return $ SimpleStmt bindType

bindingType' :: Parser BindingType
bindingType' = do
  bindNames <-  (parens (commaSep1 bindingName')
            <|> (bindingName' >>= (\b -> return $ [b])))
  relation <- relationship'
  ty <- type'
  return $ BType bindNames relation ty

relationship' :: Parser Relationship
relationship' =   subsetOf'
              <|> elementOf'

subsetOf' = subsetOp' >> return SubsetOf
elementOf' = inOp' >> return ElementOf

type' :: Parser Type
type' = buildExpressionParser operatorsTy' typeExpr'

operatorsTy' = [
                  [Infix (unionOp'         >> return (TBinOp Union)) AssocLeft,
                  Infix  (intersecOp'      >> return (TBinOp Intersection)) AssocLeft,
                  Infix  (cartProdOp'      >> return (TBinOp CartProduct)) AssocLeft,
                  Infix  (relDiffOp'       >> return (TBinOp Difference)) AssocLeft,
                  Infix  (funOp'           >> return (TBinOp Function)) AssocLeft]
               ]

unionOp' = (reserved "union" <|> reservedOp "∪")
intersecOp' = (reserved "intersection" <|> reservedOp "∩")
cartProdOp' = (reservedOp "*'" <|> reservedOp "×")
relDiffOp' = (reservedOp "\\")
funOp' = (reservedOp "->" <|> reservedOp "→")

typeExpr' :: Parser Type
typeExpr' =   typeUniverse'
          <|> typeCustom'
          <|> typeGroup'

typeUniverse' = reserved "Universe" >> return TUniverse
typeCustom' = do
  bindName <- bindingName'
  return $ TCustom bindName
typeGroup' = do
  ty <- parens type'
  return $ TGroup ty

parseWithEof :: Parser a -> String -> Either ParseError a
parseWithEof p = parse (p <* eof) ""

parseFile :: String -> Either ParseError Program 
parseFile file =
  case parseWithEof parse' file of
    Left e  -> Left e
    Right r -> Right (Prog r)
