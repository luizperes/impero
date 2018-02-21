# Impero EBNF and Railroad diagram

- EBNF
  - [begin_stmt](#begin_stmt)
  - [lib_stmt](#lib_stmt)
  - [use_stmt](#use_stmt)
  - [do_stmt](#do_stmt)
  - [let_stmt](#let_stmt)
  - [pattern_stmt](#pattern_stmt)
  - [simple_stmt](#simple_stmt)
  - [for_all_stmt](#for_all_stmt)
  - [there_exists_stmt](#there_exists_stmt)
  - [function_call](#function_call)
  - [function_call_expr](#function_call_expr)
  - [binding](#binding)
  - [expr](#expr)
  - [relational_expr](#relational_expr)
  - [additive_expr](#additive_expr)
  - [multiplicative_expr](#multiplicative_expr)
  - [power_expr](#power_expr)
  - [primary_expr](#primary_expr)
  - [binding_type](#binding_type)
  - [relationship](#relationship)
  - [type](#type)
  - [binding_name](#binding_name)
  - [identifier](#identifier)
  - [constant](#constant)
  - [set](#set)
  - [tuple](#tuple)
  - [range](#range)
  - [number](#number)
  - [float](#float)
  - [digit](#digit)
  - [letter](#letter)
  - [other_symbol](#other_symbol)
  - [start_symbol](#start_symbol)

###### begin\_stmt
```EBNF
begin_stmt ::= lib_stmt
             | use_stmt
             | let_stmt
             | do_stmt
```
<p align="left">
  <a href="">
    <img alt="BeginStmt" src="./img/begin_stmt.png" />
  </a>
</p>

###### lib\_stmt
```EBNF
lib_stmt ::= "lib" binding_name
```
<p align="left">
  <a href="">
    <img alt="LibStmt" src="./img/lib_stmt.png" />
  </a>
</p>

###### use\_stmt
```EBNF
use_stmt ::= "use" binding_name
```
<p align="left">
  <a href="">
    <img alt="UseStmt" src="./img/use_stmt.png" />
  </a>
</p>

###### do\_stmt
```EBNF
do_stmt ::= "do" function_call
```
<p align="left">
  <a href="">
    <img alt="DoStmt" src="./img/do_stmt.png" />
  </a>
</p>

###### function\_call
```EBNF
function_call ::= constant
                | binding_name ('.' | '∘') function_call
```
<p align="left">
  <a href="">
    <img alt="FunctionCall" src="./img/function_call.png" />
  </a>
</p>

###### let\_stmt
```EBNF
let_stmt ::= "let" binding+
```
<p align="left">
  <a href="">
    <img alt="LetStmt" src="./img/let_stmt.png" />
  </a>
</p>

###### binding
```EBNF
binding ::= binding_name '=' pattern_stmt ':' expr (',' expr)*
```
<p align="left">
  <a href="">
    <img alt="Binding" src="./img/binding.png" />
  </a>
</p>

###### pattern\_stmt
```EBNF
pattern_stmt ::= for_all_stmt
               | there_exists_stmt
               | simple_stmt
               | expr
               | pattern_stmt (',' pattern_stmt)+
```
<p align="left">
  <a href="">
    <img alt="PatternStmt" src="./img/pattern_stmt.png" />
  </a>
</p>

###### simple\_stmt
```EBNF
simple_stmt ::= binding_type
```
<p align="left">
  <a href="">
    <img alt="SimpleStmt" src="./img/simple_stmt.png" />
  </a>
</p>

###### expr
```EBNF
expr ::= relational_expr
       | (expr '=' relational_expr)
       | (expr '~' relational_expr)
```
<p align="left">
  <a href="">
    <img alt="Expr" src="./img/expr.png" />
  </a>
</p>

###### relational\_expr
```EBNF
relational_expr ::= additive_expr
                  | (relational_expr '>' additive_expr)
                  | (relational_expr '>=' additive_expr)
                  | (relational_expr '<' additive_expr)
                  | (relational_expr '<=' additive_expr)
```
<p align="left">
  <a href="">
    <img alt="RelationalExpr" src="./img/relational_expr.png" />
  </a>
</p>

###### additive\_expr
```EBNF
additive_expr ::= multiplicative_expr
                | (additive_expr '+' multiplicative_expr)
                | (additive_expr '-' multiplicative_expr)
```
<p align="left">
  <a href="">
    <img alt="AdditiveExpr" src="./img/additive_expr.png" />
  </a>
</p>

###### multiplicative\_expr
```EBNF
multiplicative_expr ::= power_expr
                      | (multiplicative_expr '*' power_expr)
                      | (multiplicative_expr '/' power_expr)
                      | (multiplicative_expr '%' power_expr)
```
<p align="left">
  <a href="">
    <img alt="MultiplicativeExpr" src="./img/multiplicative_expr.png" />
  </a>
</p>

###### power\_expr
```EBNF
power_expr ::= primary_expr
             | (power_expr '^' primary_expr)
```
<p align="left">
  <a href="">
    <img alt="PowerExpr" src="./img/power_expr.png" />
  </a>
</p>

###### function\_call\_expr
```EBNF
function_call_expr ::= binding_name ('.' | '∘') expr
```
<p align="left">
  <a href="">
    <img alt="FunctionCallExpr" src="./img/function_call_expr.png" />
  </a>
</p>

###### primary\_expr
```EBNF
primary_expr ::= function_call_expr
               | binding_name
               | constant
               | '(' expr ')'
```
<p align="left">
  <a href="">
    <img alt="PrimaryExpr" src="./img/primary_expr.png" />
  </a>
</p>

###### for\_all\_stmt
```EBNF
for_all_stmt ::= ("for" "all" | '∀') (binding_type | '(' binding_type (',' binding_type)+ ')')
```
<p align="left">
  <a href="">
    <img alt="ForAllStmt" src="./img/for_all_stmt.png" />
  </a>
</p>

###### there\_exists\_stmt
```EBNF
there_exists_stmt ::= ("there" "exists" | '∃') (binding_type | '(' binding_type (',' binding_type)+ ')')
```
<p align="left">
  <a href="">
    <img alt="ThereExistsStmt" src="./img/there_exists_stmt.png" />
  </a>
</p>

###### binding\_type
```EBNF
binding_type ::= binding_name relationship type
```
<p align="left">
  <a href="">
    <img alt="BindingType" src="./img/binding_type.png" />
  </a>
</p>

###### relationship
```EBNF
relatioship ::= ("subset" "of" | '⊆')
              | ("in" | '∈')
```
<p align="left">
  <a href="">
    <img alt="Relationship" src="./img/relationship.png" />
  </a>
</p>

###### type
```EBNF
type ::= 'Z'
       | 'N'
       | 'R'
       | "Universe"
       | set
       | binding_name
```
<p align="left">
  <a href="">
    <img alt="Type" src="./img/type.png" />
  </a>
</p>

###### binding\_name
```EBNF
binding_name ::= identifier
```
<p align="left">
  <a href="">
    <img alt="BindingName" src="./img/binding_name.png" />
  </a>
</p>

###### identifier
```EBNF
identifier ::= (letter | start_symbol) (letter | digit | start_symbol | other_symbol )*
```
<p align="left">
  <a href="">
    <img alt="Identifier" src="./img/identifier.png" />
  </a>
</p>

###### constant
```EBNF
constant ::= number
           | char
           | range
           | tuple
           | set
```
<p align="left">
  <a href="">
    <img alt="Constant" src="./img/constant.png" />
  </a>
</p>

###### set
```EBNF
set ::= '{' expr (',' expr)* '}'
```
<p align="left">
  <a href="">
    <img alt="Set" src="./img/set.png" />
  </a>
</p>

###### tuple
```EBNF
tuple ::= '(' expr (',' expr)* ')'
```
<p align="left">
  <a href="">
    <img alt="Tuple" src="./img/tuple.png" />
  </a>
</p>

###### range
```EBNF
range ::= expr ".." expr
```
<p align="left">
  <a href="">
    <img alt="Range" src="./img/range.png" />
  </a>
</p>

###### number
```EBNF
number ::= '-' number
         | digit+
         | float
```
<p align="left">
  <a href="">
    <img alt="Number" src="./img/number.png" />
  </a>
</p>

###### float
```EBNF
float ::= digit+ '.' digit
```
<p align="left">
  <a href="">
    <img alt="Float" src="./img/float.png" />
  </a>
</p>

###### digit
```EBNF
digit ::= '0'
        | '1'
        | "..."
        | '9'
```
<p align="left">
  <a href="">
    <img alt="Digit" src="./img/digit.png" />
  </a>
</p>

###### letter
```EBNF
letter ::= 'a'
         | 'b'
         | "..."
         | 'z'
         | 'A'
         | ".."
         | 'Z'
```
<p align="left">
  <a href="">
    <img alt="Letter" src="./img/letter.png" />
  </a>
</p>

###### other\_symbol
```EBNF
ther_symbol ::= '+'
               | '-'
               | '*'
               | '/'
               | '%'
               | '^'
               | '<'
               | '>'
```
<p align="left">
  <a href="">
    <img alt="OtherSymbol" src="./img/other_symbol.png" />
  </a>
</p>

###### start\_symbol
```EBNF
start_symbol ::= '!'
               | '@'
               | '$'
               | '_'
               | '?'
               | '|'
```
<p align="left">
  <a href="">
    <img alt="StartSymbolr" src="./img/start_symbol.png" />
  </a>
</p>