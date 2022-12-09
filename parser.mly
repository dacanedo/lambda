
%{
  open Lambda;;
%}

%token LAMBDA
%token TRUE
%token FALSE
%token IF
%token THEN
%token ELSE
%token SUCC
%token PRED
%token ISZERO
%token LET
%token LETREC
%token IN
%token BOOL
%token NAT
%token STRING
%token CONCAT

%token LPAREN
%token RPAREN
%token DOT
%token EQ
%token COLON
%token ARROW
%token EOF
%token LBRACE
%token RBRACE
%token COMMA

%token <int> INTV
%token <string> STRINGV
%token <string> STRV

%start s
%type <Lambda.command> s

%%

s :
    STRINGV EQ term EOF
      { Bind ($1, $3) }
  | term EOF
      { Eval $1 }

term :
    appTerm
      { $1 }
  | IF term THEN term ELSE term
      { TmIf ($2, $4, $6) }
  | LAMBDA STRINGV COLON ty DOT term
      { TmAbs ($2, $4, $6) }
  | LET STRINGV EQ term IN term
      { TmLetIn ($2, $4, $6) }
  | LETREC STRINGV COLON ty EQ term IN term
      { TmLetIn ($2, TmFix (TmAbs ($2, $4, $6)), $8) }

appTerm :
    atomicTerm
      { $1 }
  | SUCC atomicTerm
      { TmSucc $2 }
  | PRED atomicTerm
      { TmPred $2 }
  | ISZERO atomicTerm
      { TmIsZero $2 }
  | CONCAT atomicTerm atomicTerm
      { TmConcat ($2, $3) }
  | appTerm atomicTerm
      { TmApp ($1, $2) }

projTermT :
    atomicTerm
      { [$1] }
  | atomicTerm COMMA projTermT
      {([$1] @ $3) }

projTermR :
    STRINGV COLON atomicTerm
      { [($1, $3)] }
  | STRINGV COLON atomicTerm COMMA projTermR
      { ([($1, $3)] @ $5) }

atomicTerm :
    LPAREN term RPAREN
      { $2 }
  | TRUE
      { TmTrue }
  | FALSE
      { TmFalse }
  | STRINGV
      { TmVar $1 }
  | INTV
      { let rec f = function
            0 -> TmZero
          | n -> TmSucc (f (n-1))
        in f $1 }
  | STRV 
      { TmString $1 }
  | LBRACE RBRACE
      { TmReg [] }
  | LBRACE projTermT RBRACE
      { TmTuple $2 }
  | LBRACE projTermR RBRACE
      { TmReg $2 }

ty :
    atomicTy
      { $1 }
  | atomicTy ARROW ty
      { TyArr ($1, $3) }

atomicTy :
    LPAREN ty RPAREN  
      { $2 } 
  | BOOL
      { TyBool }
  | NAT
      { TyNat }
  | STRING
      { TyString }

