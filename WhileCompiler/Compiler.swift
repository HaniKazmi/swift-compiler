//
//  Compiler.swift
//  WhileCompiler
//
//  Created by Hani Kazmi on 08/12/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

typealias Mem = [String:Int]
typealias Instrs = [String]

func compile_aexp(a: AExp, env: Mem) -> Instrs {
    switch a {
    case let a as Num: return ["ldc \(a.i)"]
    case let a as Var: return ["iload \(env[a.s]!)"]
    case let a as Aop where a.o == "+": return compile_aexp(a.a1, env) + compile_aexp(a.a2, env) + ["iadd"]
    case let a as Aop where a.o == "-": return compile_aexp(a.a1, env) + compile_aexp(a.a2, env) + ["isub"]
    case let a as Aop where a.o == "*": return compile_aexp(a.a1, env) + compile_aexp(a.a2, env) + ["imul"]
    case let a as Aop where a.o == "/": return compile_aexp(a.a1, env) + compile_aexp(a.a2, env) + ["idiv"]
    default: return []
    }
}

func compile_bexp(b: BExp, env: Mem, jmp: String) -> Instrs {
    switch b {
    case let b as Bop where b.o == "=": return compile_aexp(b.a1, env) + compile_aexp(b.a2, env) + ["if_icmpne \(jmp)"]
    case let b as Bop where b.o == "!=": return compile_aexp(b.a1, env) + compile_aexp(b.a2, env) + ["if_icmpeq \(jmp)"]
    case let b as Bop where b.o == ">": return compile_aexp(b.a1, env) + compile_aexp(b.a2, env) + ["if_icmple \(jmp)"]
    case let b as Bop where b.o == "<": return compile_aexp(b.a1, env) + compile_aexp(b.a2, env) + ["if_icmpge \(jmp)"]
    default: return []
    }
}

var var_count = 0
func calc_store(var env: Mem, i: String) -> Mem {
    if env[i] == nil { env[i] = var_count++ }
    return env
}

var labl_count = 0
func calc_labl(x: String) -> String {
    return "\(x)_\(labl_count++)"
}

func compile_stmt(s: Stmt, env: Mem) -> (i: Instrs, e: Env) {
    switch s {
    case is Skip: return ([], env)
    case let s as Assign: let e = calc_store(env, s.s); return (compile_aexp(s.a, e) + ["istore \(e[s.s]!)"], e)
    case let s as If:
        let if_else = calc_labl("if_else")
        let if_end = calc_labl("if_end")
        let (i_bl, e) = compile_bl(s.bl1, env)
        let (e_bl, e2) = compile_bl(s.bl2, e)
        let If = compile_bexp(s.a, env, if_else)
        let Then = i_bl + ["goto \(if_end)"]
        let Else = ["\n\(if_else):\n"] + e_bl + ["\n\(if_end):\n"]
        return (If + Then + Else, e2)
    case let s as While:
        let w_begin = calc_labl("loop_begin")
        let w_end = calc_labl("loop_end")
        let (bl, e) = compile_bl(s.bl, env)
        let test = ["\n\(w_begin):\n"] + compile_bexp(s.b, env, w_end)
        let asm = bl + ["goto \(w_begin)"] + ["\n\(w_end):\n"]
        return (test + asm, e)
    case let s as Read: let e = calc_store(env, s.s); return ([lRead] + ["istore \(e[s.s]!)"], e)
    case let s as WriteS: return (["ldc \(s.s)"] + [lWriteS], env)
    case let s as Write: return (compile_aexp(s.s, env) + [lWrite], env)
    default: return ([], env)
    }
}

func compile_bl(bl: Block, env: Mem) -> (i: Instrs, e: Env) {
    if isEmpty(bl) { return ([], env) }
    let (i, e) = compile_stmt(bl.first!, env)
    let (i2, e2) = compile_bl(bl.tail, e)
    return  (i+i2, e2)
}

func compile(bl: Block) -> String {
    return Header + compile_bl(bl, Mem()).i.reduce("") { $0 + $1 + "\n" } + Footer
}

let Compile = { compile(satisfy(lstmts($0))) }

func compile_file(path: String = Process.arguments[1]) {
    let content = readfile(path)
    let file_name = path.lastPathComponent.componentsSeparatedByString(".")[0]
    let compiled = Compile(tokeniser(tok(content))).stringByReplacingOccurrencesOfString("XXX", withString: file_name)
    writefile(compiled, file_name + ".j")
    execJasmin(file_name)
}