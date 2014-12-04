//
//  ParseTree.swift
//  Regex
//
//  Created by Hani Kazmi on 03/12/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

protocol Stmt {}
protocol AExp {}
protocol BExp {}

typealias Block = [Stmt]

struct Skip: Stmt {}
struct If: Stmt { let a: BExp, bl1: Block, bl2: Block }
struct While: Stmt { let b: BExp, bl: Block }
struct Assign: Stmt { let s: String, a: AExp }

struct Var: AExp { let s: String }
struct Num: AExp { let i: Int }
struct Aop: AExp { let o: String, a1: AExp, a2: AExp }

struct True: BExp {}
struct False: BExp {}
struct Bop: BExp { let o: String, a1: AExp, a2: AExp }

func aexp() -> (String) -> [(AExp, String)] {
    func aop(s: String) -> String -> [(AExp, String)] {
        return lTe ~ /s ~ laexp ==> { let ((x, _), z) = $0; return Aop(o: s, a1: x, a2: z) } }
    return aop("+") || aop("-") || lTe
}
let laexp = lazy(aexp)

func Te() -> (String) -> [(AExp, String)] {
    func aop(s: String) -> (String) -> [(AExp, String)] {
        return lFa ~ /s ~ lTe ==> { let ((x, _), z) = $0; return Aop(o: s, a1: x, a2: z) } }
    return aop("*") || aop("/") || lFa
}
let lTe = lazy(Te)

func Fa() -> (String) -> [(AExp, String)] {
    return (/"(" ~ laexp ~ /")" ==> { let ((x, y), z) = $0; return y } ) || ( IdParser() ==> { Var(s: $0) } ) || ( NumParse() ==> { Num(i: $0) } )
}
let lFa = lazy(Fa)

func bexp() -> (String) -> [(BExp, String)] {
    func b(s: String) -> (String) -> [(BExp, String)] {
        return (laexp ~ /s ~ laexp) ==> { let ((x, _), z) = $0; return Bop(o: s, a1: x, a2: z) } }
    
    return b("==") || b("!=") || b("<") || b(">") ||
        ( /"true" ==> {  $0;return True() } ) ||
        ( /"false" ==> { $0; return False() } ) ||
        ( (/"(" ~ lbexp ~ /")") ==> { let ((x, y), z) = $0;  return y } )
}
let lbexp = lazy(bexp)

func stmt() -> (String) -> [(Stmt, String)] {
    return ( /"skip" ==> { $0; return Skip() } ) ||
        ( (IdParser() ~ /":=" ~ laexp) ==> { let ((x, _), z) = $0; return Assign(s: x, a: z) } ) ||
        ( (/"if" ~ lbexp ~ /"then" ~ lblock ~ /"else" ~ lblock) ==>
            { let (((((_,y),_),u),_),w) = $0; return If(a: y, bl1: u, bl2: w) } ) ||
        ( (/"while" ~ lbexp ~ /"do" ~ lblock) ==> { let (((_, y), _), w) = $0; return While(b: y, bl: w) } )
}
let lstmt = lazy(stmt)

func stmts() -> (String) -> [(Block, String)] {
    return ((lstmt ~ /";" ~ lstmts) ==> { let ((x, _), z) = $0; return [x] + z } ) ||
        ( lstmt ==> { [$0] } )
}
let lstmts = lazy(stmts)

func block() -> (String) -> [(Block, String)] {
    return   ((/"{" ~ lstmts ~ /"}") ==> { let ((_, y), _) = $0; return y} ) ||
        (lstmt ==> { [$0] })
}
let lblock = lazy(block)