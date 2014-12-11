//
//  ParseTree.swift
//  WhileCompiler
//
//  Created by Hani Kazmi on 03/12/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

// MARK: - Tree declaration
class Stmt {}
class AExp {}
class BExp {}

typealias Block = [Stmt]

class Skip: Stmt {}
class If: Stmt {
    let a: BExp, bl1: Block, bl2: Block
    init(a: BExp, bl1: Block, bl2: Block) {self.a = a; self.bl1 = bl1; self.bl2 = bl2 }
}
class While: Stmt {
    let b: BExp, bl: Block
    init(b: BExp, bl: Block) { self.b = b; self.bl = bl }
}
class For: Stmt {
    let a: Assign, i: AExp, bl: Block
    init(a: Assign, i: AExp, bl: Block) { self.a = a; self.i = i; self.bl = bl }
}
class Assign: Stmt {
    let s: String, a: AExp
    init(s: String, a: AExp) { self.s = s; self.a = a }
}
class Read: Stmt {
    let s: String
    init(_ s: String) { self.s = s }
}
class WriteS: Stmt {
    let s: String
    init(_ s: String) { self.s = s }
}
class Write: Stmt {
    let s: AExp
    init(_ s: AExp) { self.s = s }
}

class Var: AExp {
    let s: String
    init(_ s: String) { self.s = s }
}
class Num: AExp {
    let i: Int
    init(_ i: Int) { self.i = i }
}
class Aop: AExp {
    let o: String, a1: AExp, a2: AExp
    init(o: String, a1: AExp, a2: AExp) { self.o = o; self.a1 = a1; self.a2 = a2 }
}

class True: BExp {}
class False: BExp {}
class Bop: BExp {
    let o: String, a1: AExp, a2: AExp
    init(o: String, a1: AExp, a2: AExp) { self.o = o; self.a1 = a1; self.a2 = a2 }
}

// MARK: - Arithmetic expressions
func aexp() -> ([Token]) -> [(AExp, [Token])] {
    func aop(s: String) -> [Token] -> [(AExp, [Token])] {
        return lTe ~ /T_OP(s: s) ~ laexp ==> { let ((x, _), z) = $0; return Aop(o: s, a1: x, a2: z) }
    }
    return aop("+") || aop("-") || lTe
}
let laexp = lazy(aexp)

func Te() -> ([Token]) -> [(AExp, [Token])] {
    func aop(s: String) -> ([Token]) -> [(AExp, [Token])] {
        return lFa ~ /T_OP(s: s) ~ lTe ==> { let ((x, _), z) = $0; return Aop(o: s, a1: x, a2: z) }
    }
    return aop("*") || aop("/") || lFa
}
let lTe = lazy(Te)

func Fa() -> ([Token]) -> [(AExp, [Token])] {
    return (/T_PAREN(s: "(") ~ laexp ~ /T_PAREN(s: ")") ==> { let ((x, y), z) = $0; return y } ) ||
        IdParser() ==> { Var($0) }  || NumParser() ==> { Num($0) }
}
let lFa = lazy(Fa)

// MARK: - Boolean expressions
func bexp() -> ([Token]) -> [(BExp, [Token])] {
    func b(s: String) -> ([Token]) -> [(BExp, [Token])] {
        return (laexp ~ /T_OP(s: s) ~ laexp) ==> { let ((x, _), z) = $0; return Bop(o: s, a1: x, a2: z) } }
    
    return b("==") || b("!=") || b("<") || b(">") ||
        /T_KWD(s: "true") ==> { _ in True() } ||
        /T_KWD(s: "false") ==> { _ in False() } ||
        /T_PAREN(s: "(") ~ lbexp ~ /T_PAREN(s: ")") ==> { let ((x, y), z) = $0;  return y }
}
let lbexp = lazy(bexp)

// MARK: - Statements
func stmt() -> ([Token]) -> [(Stmt, [Token])] {
    typealias ret = [Token] -> [(Stmt, [Token])]
    let skip: ret = /T_KWD(s: "skip") ==> { _ in Skip() }
    let assign: ret = IdParser() ~ /T_OP(s: ":=") ~ laexp ==> { let ((x, _), z) = $0; return Assign(s: x, a: z) }
    let pIf: ret = /T_KWD(s: "if") ~ lbexp ~ /T_KWD(s: "then") ~ lblock ~ /T_KWD(s: "else") ~ lblock ==>
        { let (((((_,y),_),u),_),w) = $0; return If(a: y, bl1: u, bl2: w) }
    let pWhile: ret = /T_KWD(s: "while") ~ lbexp ~ /T_KWD(s: "do") ~ lblock ==>
        { let (((_, y), _), w) = $0; return While(b: y, bl: w) }
    let pFor: ret = /T_KWD(s: "for") ~ assign ~ /T_KWD(s: "upto") ~ laexp ~ /T_KWD(s: "do") ~ lblock ==>
        { let (((((_, y), _), u), _), w) = $0; return For(a: y as Assign, i: u, bl: w) }
    let read: ret = /T_KWD(s: "read") ~ IdParser() ==> { let (_, y) = $0; return Read(y) }
    let writeS: ret = /T_KWD(s: "write") ~ StringParser() ==> { let (_, y) = $0; return WriteS(y) }
    let write: ret = /T_KWD(s: "write") ~ laexp ==> { let (_, y) = $0; return Write(y) }
    
    return skip || assign || pIf || pWhile || pFor || writeS || write || read
}
let lstmt = lazy(stmt)

func stmts() -> ([Token]) -> [(Block, [Token])] {
    return lstmt ~ /T_SEMI() ~ lstmts ==> { let ((x, _), z) = $0; return [x] + z } ||
        lstmt ==> { [$0] }
}
/// Converts tokens into a parse tree
let lstmts = lazy(stmts)

func block() -> ([Token]) -> [(Block, [Token])] {
    return /T_PAREN(s: "{") ~ lstmts ~ /T_PAREN(s: "}") ==> { let ((_, y), _) = $0; return y} ||
        lstmt ==> { [$0] }
}
let lblock = lazy(block)