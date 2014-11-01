//
//  tokeniser.swift
//  Regex
//
//  Created by Hani Kazmi on 27/10/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

protocol Val: Printable {}
struct empty: Val { var description: String { return "empty"} }
struct char: Val { let c: Character; var description: String { return "\(self.c)"} }
struct seq: Val { let v1: Val, v2: Val; var description: String { return "seq(\(self.v1), \(self.v2))"} }
struct left: Val { let v: Val; var description: String { return "left(\(self.v))"} }
struct right: Val { let v: Val; var description: String { return "right(\(self.v))"} }
struct stars: Val { let vs: [Val]; var description: String { return "stars"} }
struct rec: Val { let x:String, v: Val; var description: String { return x} }

func mkeps(r: Rexp) -> Val {
    switch r {
    case is Empty: return empty()
    case let r as Alt: return nullable(r.r1) ? left(v: mkeps(r.r1)) : right(v: mkeps(r.r2))
    case let r as Seq: return seq(v1: mkeps(r.r1), v2: mkeps(r.r2))
    case is Star: return stars(vs: [Val]())
    case let r as Rec: return rec(x: r.x, v: mkeps(r.r))
    default: return empty()
    }
}

func inj(r: Rexp, c: Character, v: Val) -> Val {
    switch (r, v) {
    case (is Char, is empty): return char(c: c)
    case let (r as Alt, v as left): return left(v: inj(r.r1, c, v.v))
    case let (r as Alt, v as right): return right(v: inj(r.r2, c, v.v))
    case let (r as Seq, v as seq): return seq(v1: inj(r.r1, c, v.v1), v2: v.v2)
    case let (r as Seq, v as left): let w = v.v as seq; return seq(v1: inj(r.r1, c, w.v1), v2: w.v2)
    case let (r as Seq, v as right): return seq(v1: mkeps(r.r1), v2: inj(r.r2, c, v.v))
    case let (r as Star, v as seq): return stars(vs: [inj(r.r, c, v.v1), v.v2])
    case (let r as Rec, _): return rec(x: r.x, v: inj(r.r, c, v))
    default: return empty()
    }
}

func lex(r: Rexp, s:String) -> Val {
   // println(r)
    if s.isEmpty { return mkeps(r) }
    return inj(r, s[0], lex(der(s[0], r), s[1..<s.count]))
}

extension String {
    subscript(index:Int) -> Character{
        return self[advance(self.startIndex, index)]
    }
    
    subscript(range: Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self[start..<end]
    }
    
    var count: Int { return self.utf16Count }
}

let keywords = /"while" | /"if"