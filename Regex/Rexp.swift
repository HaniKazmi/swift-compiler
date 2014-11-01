//
//  Rexp.swift
//  Regex
//
//  Created by Hani on 01/10/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

class Rexp {}
class UnaryRexp: Rexp { let r: Rexp; init(_ r: Rexp) { self.r = r } }
class BinaryRexp: Rexp { let r1: Rexp, r2: Rexp; init(_ r1: Rexp, _ r2: Rexp) { self.r1 = r1; self.r2 = r2 } }

class Null: Rexp {}
class Empty: Rexp {}
class Char: Rexp { let c: Character; init(_ c: Character) { self.c = c } }

class Alt: BinaryRexp {}
class Seq: BinaryRexp {}
class Star: UnaryRexp {}

class Chars: Rexp { let c: [Character]; init(_ c: String) { self.c = Array(c) } }
class Plus: UnaryRexp {}
class Opt: UnaryRexp {}
class Ntimes: Rexp { let r: Rexp, n: Int; init(_ r: Rexp, _ n: Int) { self.r = r; self.n = n } }
class Mult: Rexp { let r: Rexp, n: Int, m: Int; init(r: Rexp, n: Int, m: Int) { self.r = r; self.n = n; self.m = m} }
class Not: UnaryRexp {}

class Rec: Rexp { let x: String, r: Rexp; init(_ x: String, _ r: Rexp) { self.x = x; self.r = r } }

extension Rexp: Printable {
    var description: String {
        switch self {
        case is Null: return "Null"
        case is Empty: return "Empty"
        case let r as Char: return "\(r.c)"
        case let r as Alt: return "Alt(\(r.r1), \(r.r2))"
        case let r as Seq: return "Seq(\(r.r1), \(r.r2))"
        case let r as Star: return "Star(\(r.r))"
        case let r as Chars: return "Range"
        case let r as Plus: return "Opt(\(r.r))"
        case let r as Opt: return "Opt(\(r.r))"
        case let r as Ntimes: return "Mult(\(r.r), \(r.n))"
        case let r as Mult: return "Mult(\(r.r), \(r.n), \(r.m))"
        case let r as Not: return "Not(\(r.r))"
        case let r as Rec: return r.x
        default: return "Error"
        }
    }
}

func nullable(r: Rexp) -> Bool {
    switch r {
    case is Null: return false
    case is Empty: return true
    case is Char: return false
    case let r as Alt: return nullable(r.r1) || nullable(r.r2)
    case let r as Seq: return nullable(r.r1) && nullable(r.r2)
    case is Star: return true
    case is Chars: return false
    case let r as Plus: return nullable(r.r)
    case let r as Opt: return true
    case let r as Ntimes: return r.n == 0 ? true : nullable(r.r)
    case let r as Mult: return r.n <= 0 ? true : nullable(r.r)
    case let r as Not: return !nullable(r.r)
    case let r as Rec: return nullable(r.r)
    default: return false
    }
}

func der(c: Character, r: Rexp) -> Rexp {
    switch r {
    case is Null: return Null()
    case is Empty: return Null()
    case let r as Char: return c == r.c ? Empty() : Null()
    case let r as Alt: return Alt(der(c, r.r1), der(c, r.r2))
    case let r as Seq: return nullable(r.r1) ?
        Alt(Seq(der(c, r.r1), r.r2), der(c, r.r2)) : Seq(der(c, r.r1), r.r2)
    case let r as Star: return Seq(der(c, r.r), Star(r.r))
    case let r as Chars: return contains(r.c, c) ? Empty() : Null()
    case let r as Plus: return Seq(der(c, r.r), Star(r.r))
    case let r as Opt: return der(c, r.r)
    case let r as Ntimes: return r.n == 0 ? Null() : Seq(der(c, r.r), Ntimes(r.r, r.n-1))
    case let r as Mult: return r.m == 0 ? Null() : Seq(der(c, r.r), Mult(r: r.r, n: r.n-1, m: r.m-1))
    case let r as Not: return Not(der(c, r.r))
    case let r as Rec: return Rec(r.x, der(c, r.r))
    default: return r
    }
}

func ders(s: String, r:Rexp) -> Rexp {
   // println(r)
    if s.isEmpty { return r }
    return ders(s[1..<s.count], simp(der(s[0], r)))
}

func matches(r: Rexp, s:String) -> Bool {
    return nullable(ders(s, r))
}

func simp(r: Rexp) -> Rexp {
    switch r {
    case let r as Alt:
        switch (simp(r.r1), simp(r.r2)) {
        case (is Null, let r2): return r2
        case (let r1, is Null): return r1
        case let (r1, r2) where r1==r2: return r1
        case let (r1, r2): return Alt(r1, r2)
        }
        
    case let r as Seq:
        switch (simp(r.r1), simp(r.r2)) {
        case (is Null, _): return Null()
        case (_, is Null): return Null()
        case (is Empty, let r2): return r2
        case (let r1, is Empty): return r1
        case let (r1, r2): return Seq(r1, r2)
        }
    
    case let r as Ntimes: return Ntimes(simp(r.r), r.n)
    case let r as Mult: return Mult(r: simp(r.r), n: r.n, m: r.m)
    case let r as Plus: return Plus(simp(r.r))
    case let r as Star: return Star(simp(r.r))
    default: return r
    }
}

func count(r: Rexp) -> Int {
    switch r{
    case let r as BinaryRexp: return 1 + count(r.r1) + count(r.r2)
    case let r as UnaryRexp: return 1 + count(r.r)
    case let r as Ntimes: return 1 + count(r.r)
    case let r as Mult: return 1 + count(r.r)
    default: return 1
    }
}

func stringToRexp(var s: String) -> Rexp {
    return s.count == 1 ? Char(s[0]) : Seq(Char(s[0]), stringToRexp(s[1..<s.count]))
}

func ==(r1: Rexp, r2: Rexp) -> Bool {
    switch (r1, r2) {
    case is (Null, Null): return true
    case is (Empty, Empty): return true
    case let (r1 as Char, r2 as Char): return r1.description == r2.description
    case let (r1 as Alt, r2 as Alt): return r1.r1 == r2.r1 && r1.r2 == r2.r2
    case let (r1 as Seq, r2 as Seq): return r1.r1 == r2.r1 && r1.r2 == r2.r2
    case let (r1 as Opt, r2 as Opt): return r1.r == r2.r
    case let (r1 as Star, r2 as Star): return r1.r == r2.r
    case let (r1 as Plus, r2 as Plus): return r1.r == r2.r
    default: return false
    }
}

func |(r1: Rexp, r2: Rexp) -> Rexp { return Alt(r1, r2) }
func &(r1: Rexp, r2: Rexp) -> Rexp { return Seq(r1, r2) }
func ^(r: Rexp, p:[Int]) -> Rexp { return Mult(r: r, n: p[0], m: p[1]) }
infix operator ~ {}
func ~(x: String, r: Rexp) -> Rexp { return Rec(x, r) }

prefix func !(r: Rexp) -> Rexp { return Not(r) }
prefix operator / {}
prefix func /(s: String) -> Rexp { return stringToRexp(s) }

postfix operator * {}
postfix func *(r: Rexp) -> Rexp { return Star(r) }
postfix operator + {}
postfix func +(r: Rexp) -> Rexp { return Plus(r) }
postfix operator % {}
postfix func %(r: Rexp) -> Rexp { return Opt(r) }