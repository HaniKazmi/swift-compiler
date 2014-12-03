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
    return ( lazy(Te) ~ /"+" ~ lazy(aexp) ==> { let ((x, _), z) = $0; return Aop(o: "+", a1: x, a2: z) } ) ||
        ( lazy(Te) ~ /"-" ~ lazy(aexp) ==>  { let ((x, _), z) = $0; return Aop(o: "-", a1: x, a2: z) } ) || lazy(Te)
}

func Te() -> (String) -> [(AExp, String)] {
    return ( lazy(Fa) ~ /"*" ~ lazy(Te) ==> { let ((x, _), z) = $0; return Aop(o: "-", a1: x, a2: z) } ) ||
        ( lazy(Fa) ~ /"/" ~ lazy(Te) ==> { let ((x, _), z) = $0; return Aop(o: "/", a1: x, a2: z) } ) || lazy(Fa)
}

func Fa() -> (String) -> [(AExp, String)] {
    return (/"(" ~ lazy(aexp) ~ /")" ==> { let ((x, y), z) = $0; return y } ) || ( IdParser() ==> { Var(s: $0) } ) || ( NumParse() ==> { Num(i: $0) } )
}

func bexp() -> (String) -> [(BExp, String)] {
    func b(s: String) -> (String) -> [(BExp, String)] {
        return (lazy(aexp) ~ /s ~ lazy(aexp)) ==> { let ((x, y), z) = $0; return Bop(o: s, a1: x, a2: z) }
    }
    
    return b("==") || b("!=") || b("<") || b(">") ||
        ( /"true" ==> {  $0;return True() } ) ||
        ( /"false" ==> { $0; return False() } ) ||
        ( (/"(" ~ lazy(bexp) ~ /")") ==> { let ((x, y), z) = $0;  return y } )
}

func stmt() -> (String) -> [(Stmt, String)] {
    return ( /"skip" ==> { $0; return Skip() } ) ||
        ( (IdParser() ~ /":=" ~ lazy(aexp)) ==> { let ((x, _), z) = $0; return Assign(s: x, a: z) } ) ||
        ( (/"if" ~ lazy(bexp) ~ /"then" ~ lazy(block) ~ /"else" ~ lazy(block)) ==>
            { let (((((_,y),_),u),_),w) = $0; return If(a: y, bl1: u, bl2: w) } ) ||
        ( (/"while" ~ lazy(bexp) ~ /"do" ~ lazy(block)) ==> { let (((_, y), _), w) = $0; return While(b: y, bl: w) } )
}

func stmts() -> (String) -> [(Block, String)] {
    return ((lazy(stmt) ~ /";" ~ lazy(stmts)) ==> { let ((x, _), z) = $0; return [x] + z } ) ||
        ( lazy(stmt) ==> { [$0] } )
}

func block() -> (String) -> [(Block, String)] {
    return   ((/"{" ~ lazy(stmts) ~ /"}") ==> { let ((_, y), _) = $0; return y} ) ||
        (lazy(stmt) ==> { [$0] })
}