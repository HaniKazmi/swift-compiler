//
//  Tokeniser.swift
//  Regex
//
//  Created by Hani Kazmi on 27/10/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

class Val {}
class void: Val {}
class char: Val { let c: Character; init(c: Character) { self.c = c} }
class seq: Val { let v1: Val, v2: Val; init(v1: Val, v2: Val) { self.v1 = v1; self.v2 = v2 } }
class left: Val { let v: Val; init(v: Val) { self.v = v} }
class right: Val { let v: Val; init(v: Val) { self.v = v} }
class stars: Val { let vs: [Val]; init(vs: [Val]) { self.vs = vs} }
class plus: Val { let vs: [Val]; init(vs: [Val]) { self.vs = vs} }
class rec: Val { let x: String, v: Val; init(x: String, v: Val) { self.x = x; self.v = v} }

extension Val: Printable {
    var description: String {
        switch self {
        case is void: return "Not matched"
        case let r as char: return "\(r.c)"
        case let r as seq: return "seq(\(r.v1), \(r.v2))"
        case let r as left: return "left(\(r.v))"
        case let r as right: return "right(\(r.v))"
        case let r as stars: return "stars(\(r.vs))"
        case let r as plus: return "plus(\(r.vs))"
        case let r as rec: return "\(r.x) : \(r.v)"
        default: return "error"
        }
    }
}

func mkeps(r: Rexp) -> Val {
    switch r {
    case is Empty: return void()
    case let r as Alt: return nullable(r.r1) ? left(v: mkeps(r.r1)) : right(v: mkeps(r.r2))
    case let r as Seq: return seq(v1: mkeps(r.r1), v2: mkeps(r.r2))
    case is Star: return stars(vs: [Val]())
    case is Plus: return plus(vs: [Val]())
    case let r as Rec: return rec(x: r.x, v: mkeps(r.r))
    default: return void()
    }
}

func inj(r: Rexp, c: Character, v: Val) -> Val {
    switch (r, v) {
    case (is Char, _): return char(c: c)
    case (is Chars, _): return char(c: c)
    case let (r as Alt, v as left): return left(v: inj(r.r1, c, v.v))
    case let (r as Alt, v as right): return right(v: inj(r.r2, c, v.v))
    case let (r as Seq, v as seq): return seq(v1: inj(r.r1, c, v.v1), v2: v.v2)
    case let (r as Seq, v as left) where v.v is seq: let w = v.v as seq; return seq(v1: inj(r.r1, c, w.v1), v2: w.v2)
    case let (r as Seq, v as right): return seq(v1: mkeps(r.r1), v2: inj(r.r2, c, v.v))
    case let (r as Star, v as seq) where v.v2 is stars: return stars(vs: [inj(r.r, c, v.v1), v.v2])
    case let (r as Plus, v as seq): return plus(vs: [inj(r.r, c, v.v1), v.v2])
    case (let r as Rec, _): return rec(x: r.x, v: inj(r.r, c, v))
    default: return void()
    }
}

func flatten(v: Val) -> String {
    switch v {
    case is void: return ""
    case let v as char: return String(v.c)
    case let v as left: return flatten(v.v)
    case let v as right: return flatten(v.v)
    case let v as seq: return flatten(v.v1) + flatten(v.v2)
    case let v as stars: return v.vs.reduce("") {$0 + flatten($1)}
    case let v as plus: return v.vs.reduce("") {$0 + flatten($1)}
    case let v as rec: return flatten(v.v)
    default: return "Error"
    }
}

typealias token = [[String:String]]

func env(v: Val) -> token {
    switch v {
    case let v as left: return env(v.v)
    case let v as right: return env(v.v)
    case let v as seq: return env(v.v1) + env(v.v2)
    case let v as stars: return v.vs.reduce([]) {$0 + env($1)}
    case let v as plus: return v.vs.reduce([]) {$0 + env($1)}
    case let v as rec: return [[v.x:flatten(v.v)]] + env(v.v)
    default: return []
    }
}

func lex(r: Rexp, s:String) -> Val {
    if s.isEmpty { return nullable(r) ? mkeps(r) : void() }
    let (r_simp, f_rect) = simp(der(s[0], r))
    return inj(r, s[0], f_rect(lex(r_simp, s[1..<s.count])))
}

func tok(r: Rexp, s:String) -> token {
    return env(lex(r, s))
}

extension String {
    subscript(index: Int) -> Character{
        return self[advance(self.startIndex, index)]
    }
    
    subscript(range: Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self[start..<end]
    }
    
    var count: Int { return self.utf16Count }
}