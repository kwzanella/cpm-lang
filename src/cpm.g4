grammar cpm;

/*
 -------------------------------------------- LEXER RULES ------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
*/

fragment LETRA: [a-zA-Z];
fragment DIGITO: [0-9];

// Incluir bibliotecas
USE: 'use' ;

// Comentário
COMMENT: '/*' .* '*/' ;

// Tipos primitivos
TIPO: 'int' | 'float' | 'void' | 'double' | 'str' | 'bool';

// Booleanos
BOOL: 'true' | 'false' ;

// Definir funções
DEF: 'def' ;

// Função principal
MAIN: 'main' ;

// Retorno de valor por função
RETURN: 'return' ;

// Estruturas condicionais
IF: 'if' ;
IFSE: 'ifse' ;
ELSE: 'else' ;

// Estruturas de repetição
WHILE: 'while' ;
FOR: 'for' ;

// Separadores
SEP_RE: '::' ;
SEP_EX: ';' ;

// Delimitadores
AC: '{' ;
FC: '}' ;
AP: '(' ;
FP: ')' ;
ACOL : '[' ;
FCOL : ']' ;

// Operadores lógicos
OP_LOG: 'and' | 'or' | 'not' ;

// Atribuição
ATR: '=' ;

// Operadores aritméticos
MAISMENOS: '+-' ;
MAISMAIS: '++' ;
MENOSMENOS: '--' ;
OP_ARIT: '+' | '-' | '*' | '/' | '%' ;

// Operadores relacionais
OP_REL: '<' | '<=' | '>=' | '>' | '==' | '!=' ;

// Números
NUM_INT: ('-' | '+')?DIGITO+ ;
NUM_FLOAT: ('-' | '+')?DIGITO+('.'DIGITO+) ;

// Strings
STR: '"' ('\\' ["\\] | ~["\\\r\n])* '"' ;

// Nome de variáveis e funções
ID: (LETRA | '_')(DIGITO | LETRA | '_')* ;

// Caracteres inúteis
WS: [ \r\t\n]* -> skip ;

// Erro
ERROR: . ;

/*
 -------------------------------------------- PARSER RULES -----------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
*/

/*
 -------------------------------------------- Estrutura --------------------------------------------------
----------------------------------------------------------------------------------------------------------
*/

// Estrutura padrão de um programa cpm
programa:
    global funcao_principal?
    ;

funcao_principal:
    DEF MAIN '()' '::' TIPO bloco
    ;

global:
    (
    bloco
    | expressao ';'
    | declaracao
    | repeticao
    | condicional
    | chamada ';'
    | importar ';'
    | retornar ';'
    )*
    ;

// Um bloco é tudo aquilo em que é necessário {}
bloco:
   '{'
   (
    bloco
    | vetor
    | funcao
    | expressao ';'
    | declaracao
    | repeticao
    | condicional
    | chamada ';'
    | importar ';'
    | retornar ';'
   )*
   '}'
   ;


/*
 -------------------------------------------- Auxiliares -------------------------------------------------
----------------------------------------------------------------------------------------------------------
*/

// Necessário para não causar recursão à esquerda nas expressões
// Mudar nome
tipos_primitivos:
    NUM_FLOAT | NUM_INT | STR | ID | BOOL | funcao | vetor
    ;

tipos_atribuicao:
    tipos_primitivos
    | expressao
    ;

parametro:
    ((tipos_primitivos | expressao) (',' (tipos_primitivos | expressao))*)
    ;

indice:
    (NUM_INT | ID | vetor | funcao | expressao)
    ;

termo_aritmetico:
    fator_aritmetico (OP_ARIT fator_aritmetico)*
    ;

fator_aritmetico:
    tipos_primitivos | '(' expressao_aritmetica ')'
    ;

termo_logico:
    fator_logico (OP_LOG fator_logico)*
    ;

fator_logico:
    ID | vetor | BOOL | '(' expressao_logica ')'
    ;

termo_relacional:
    fator_relacional (OP_REL fator_relacional)*
    ;

fator_relacional:
    tipos_primitivos  | BOOL | '(' expressao_relacional ')'
    ;

/*
 -------------------------------------------- Expressões -------------------------------------------------
----------------------------------------------------------------------------------------------------------
*/

expressao:
    expressao_aritmetica
    | expressao_logica
    | expressao_relacional
    ;

expressao_aritmetica:
    termo_aritmetico ((OP_ARIT (termo_aritmetico | termo_relacional)) | MENOSMENOS | MAISMAIS | MAISMENOS)*
    ;

expressao_logica:
    termo_logico (OP_LOG (termo_logico | termo_relacional))*
    ;

expressao_relacional:
    termo_relacional (OP_REL (termo_relacional | termo_logico))*
    ;

/*
 -------------------------------------------- Declarações ------------------------------------------------
----------------------------------------------------------------------------------------------------------
*/

declaracao:
    declaracao_variavel ';'
    | declaracao_vetor
    | declaracao_funcao
    ;

declaracao_variavel:
    TIPO ID ('=' tipos_atribuicao)?
    ;

declaracao_vetor:
    TIPO '[' (NUM_INT | ID | vetor) ']'
    ;

declaracao_funcao:
    DEF ID '(' (TIPO ID (',' TIPO ID)*) ')' '::' TIPO  bloco |
    DEF ID '()' '::' TIPO  bloco  // Gambiarra
    ;

/*
 -------------------------------------------- Repetições -------------------------------------------------
----------------------------------------------------------------------------------------------------------
*/

repeticao:
    repeticao_while
    | repeticao_for
    ;

repeticao_while:
    WHILE expressao bloco
    ;

repeticao_for:
    FOR '(' declaracao_variavel ';' expressao ';' (ID (MAISMAIS | MAISMENOS | MENOSMENOS)) ')' bloco
    ;

/*
 -------------------------------------------- Condicionais -----------------------------------------------
----------------------------------------------------------------------------------------------------------
*/

condicional:
    condicional_if
    | condcional_ifse
    | condicional_else
    ;

condicional_if:
    IF expressao bloco
    ;

condcional_ifse:
    IFSE expressao bloco
    ;

condicional_else:
    ELSE bloco
    ;

/*
 -------------------------------------------- Chamadas ---------------------------------------------------
----------------------------------------------------------------------------------------------------------
*/

chamada:
    chamada_funcao
    | chamada_atribuicao
    ;

chamada_funcao:
    ID '(' (tipos_atribuicao | /*vazio*/) ')'
    ;

chamada_atribuicao:
    (ID | vetor) '=' tipos_atribuicao
    ;

/*
 -------------------------------------------- Outros -----------------------------------------------------
----------------------------------------------------------------------------------------------------------
*/

importar:
    USE STR
    ;

vetor:
    ID '[' indice ']'
    ;

funcao:
    ID '(' parametro ')'
    ;

retornar:
    RETURN tipos_atribuicao
    ;