swift-compiler
==============

A compiler for a small turing complete language, written in Swift.

Implements a Rexp matcher using [Brzozowski derivatives](http://www.cl.cam.ac.uk/~so294/documents/jfp09.pdf), a [Sulzmann tokeniser](http://www.home.hs-karlsruhe.de/~suma0002/publications/regex-parsing-derivatives.pdf).

Creates a parse tree using [Parser Combinators](http://www.cs.nott.ac.uk/~gmh/monparsing.pdf)

Grammar
--------

### Basics
> S → C · S | C  
W → (L | N | \_) · W | L | N | \_  
C → L | N | ‘ ‘ | .   
N → N · N | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9   
L → a | b | c | d | e | f | g | h | i | j | k | l | m | n | o | p | q | r | s | t | u | v | w | x | y | z  

### Arithmetic Expressions
> E → T · + · E | T · - · E   
T → F · * · T | F · / · T   
F → ( · E · ) | ID | N  

### Boolean Expressions
> B → E · == · E | E · != · E | E · < · E | E · > · E | E · != · E | true | false  

### Statement
> STMT = SKIP | ASSIGN | IF | WHILE  | READ | WRITE  
SKIP → skip   
ASSIGN → ID · := · E   
IF → if · B · then · BL · else · BL   
WHILE → while · B · do · BL   
READ → read · ID   
WRITE → write · (E | “ · S · “)   
ID → L · W | L  

### Compound Statements
> STMTS → STMT  · ; · STMTS | STMT  

### Blocks
> BL → {  · STMTS · } | STMT  