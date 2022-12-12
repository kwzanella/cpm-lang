grammar gramatica;

fragment LETRA: [a-zA-Z];
fragment DIGITO: [0-9];

USE: 'use';
TIPO: 'int' | 'float' | 'void';
MAIN: 'main';
DEF: 'def';
IF: 'if';
IFSE: 'ifse';
ELSE: 'else';
WHILE: 'while';
RETURN: 'return';
SEP_RE: '::';
SEP_EX: ';';
AC: '{';
FC: '}';
AP: '(';
FP: ')';
ID: LETRA(DIGITO|LETRA)*;
ATR: '=';
MAISMENOS: '+-';
MAISMAIS: '++';
MENOSMENOS: '--';
OP_ARIT: '+'|'-'|'*'|'/'|'%';
NUM: DIGITO+('.'DIGITO+)?;
WS: [ \r\t\n]* ->skip;
STR: '"' ('\\' ["\\] | ~["\\\r\n])* '"';
ACOL : '[';
FCOL : ']';
OP_REL: ('<'|'<='|'>='|'>'|'='|'!=');
ERROR: . ;