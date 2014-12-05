//
//  Interpreter.swift
//  WhileCompiler
//
//  Created by Hani Kazmi on 03/12/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation
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
    case let s as Assign: env[s.s] = eval_aexp(s.a, env); return env
    case let s as If where eval_bexp(s.a, env): return eval_bl(s.bl1, env)
    case let s as If: return eval_bl(s.bl2, env)
    case let s as While where eval_bexp(s.b, env): return eval_stmt(While(b: s.b, bl: s.bl), eval_bl(s.bl, env))
    case let s as Read: env[s.s] = readln().toInt()!; return env
    case let s as WriteS: println(s.s); return env
    case let s as Write: println(eval_aexp(s.s, env)); return env
    default: return env
    }
}

func eval_bl(bl: Block, env: Env) -> Env {
    return isEmpty(bl) ? env : eval_bl(bl.tail, eval_stmt(bl.first!, env))
}

func eval(bl: Block) -> Env {
    let startTime = CFAbsoluteTimeGetCurrent()
    let x = eval_bl(bl, Env())
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    println("Time elapsed: \(timeElapsed) s")
    return x
}

let Eval = { println(eval(satisfy(lstmts($0)))) }