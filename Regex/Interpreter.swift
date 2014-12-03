//
//  Interpreter.swift
//  Regex
//
//  Created by Hani Kazmi on 03/12/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

typealias Env = [String:Int]

func eval_aexp(a: AExp, env: Env) -> Int {
    switch a {
    case let a as Num: return a.i
    case let a as Var: return env[a.s]!
    case let a as Aop where a.o == "+": return eval_aexp(a.a1, env) + eval_aexp(a.a2, env)
    case let a as Aop where a.o == "-": return eval_aexp(a.a1, env) - eval_aexp(a.a2, env)
    case let a as Aop where a.o == "*": return eval_aexp(a.a1, env) * eval_aexp(a.a2, env)
    case let a as Aop where a.o == "/": return eval_aexp(a.a1, env) &/ eval_aexp(a.a2, env)
    default: return 0
    }
}

func eval_bexp(b: BExp, env: Env) -> Bool {
    switch b {
    case is True: return true
    case is False: return false
    case let b as Bop where b.o == "=": return eval_aexp(b.a1, env) == eval_aexp(b.a2, env)
    case let b as Bop where b.o == "!=": return eval_aexp(b.a1, env) != eval_aexp(b.a2, env)
    case let b as Bop where b.o == ">": return eval_aexp(b.a1, env) > eval_aexp(b.a2, env)
    case let b as Bop where b.o == "<": return eval_aexp(b.a1, env) < eval_aexp(b.a2, env)
    default: return false
    }
}

func eval_stmt(s: Stmt, var env: Env) -> Env {
    switch s {
    case is Skip: return env
    case let s as Assign: env.updateValue(eval_aexp(s.a, env), forKey: s.s); return env
    case let s as If: if eval_bexp(s.a, env) { return eval_bl(s.bl1, env) } else { return eval_bl(s.bl2, env) }
    case let s as While: if eval_bexp(s.b, env) { return eval_stmt(While(b: s.b, bl: s.bl), eval_bl(s.bl, env)) } else { return env }
    default: return env
    }
}

func eval_bl(bl: Block, env: Env) -> Env {
    return isEmpty(bl) ? env : eval_bl(Array(bl[1..<bl.count]), eval_stmt(bl[0], env))
}

func eval(bl: Block) -> Env {
    return eval_bl(bl, Env())
}

let Eval = { println(eval(satisfy(block()($0)).first!)) }