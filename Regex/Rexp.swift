//
//  Rexp.swift
//  Regex
//
//  Created by Hani on 01/10/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

protocol Rexp: Printable {}
class UnaryRexp: Rexp { let r: Rexp; init(_ r: Rexp) { self.r = r } ; var description: String { return "" } }
class BinaryRexp: Rexp { let r1: Rexp, r2: Rexp; init(_ r1: Rexp, _ r2: Rexp) { self.r1 = r1; self.r2 = r2 } ; var description: String { return "" } }

class Null: Rexp { var description: String { return "Null" } }
class Empty: Rexp {var description: String { return "Empty" } }
extension String: Rexp { public var description: String { return "\(self)" } }
class Alt: BinaryRexp { override var description: String { return "Alt(\(self.r1), \(self.r2))" } }
class Seq: BinaryRexp { override var description: String { return "Seq(\(self.r1), \(self.r2))" } }
class Star: UnaryRexp { override var description: String { return "Star(\(self.r))" } }

class Range: Rexp { let c: [Character]; init(_ c: String) { self.c = Array(c) } ; var description: String { return "Range" } }
class Plus: UnaryRexp { override var description: String { return "Plus(\(self.r))" } }
class Opt: UnaryRexp { override var description: String { return "Opt(\(self.r))" } }
class Mult: Rexp { let r: Rexp, n: Int, m: Int; init(r: Rexp, n: Int, m: Int) {self.r = r; self.n = n; self.m = m} ; var description: String { return "Mult(\(self.r), \(self.n), \(self.m))" } }
class Not: UnaryRexp { override var description: String { return "Not(\(self.r))" } }

func nullable(r: Rexp) -> Bool {
    switch r {
    case is Null: return false
    case is Empty: return true
    case is String: return false
    case let r as Alt: return nullable(r.r1) || nullable(r.r2)
    case let r as Seq: return nullable(r.r1) && nullable(r.r2)
    case is Star: return true
    case is Range: return false
    case let r as Plus: return nullable(r.r)
    case let r as Opt: return true
    case let r as Mult: return r.n <= 0 ? true : nullable(r.r)
    case let r as Not: return !nullable(r.r)
    default: return false
    }
}

func der(c: Character, r: Rexp) -> Rexp {
    switch r {
    case is Null: return Null()
    case is Empty: return Null()
    case let r as String: return String(c) == r ? Empty() : Null()
    case let r as Alt: return Alt(der(c, r.r1), der(c, r.r2))
    case let r as Seq: return nullable(r.r1) ?
        Alt(Seq(der(c, r.r1), r.r2), der(c, r.r2)) : Seq(der(c, r.r1), r.r2)
    case let r as Star: return Seq(der(c, r.r), Star(r.r))
    case let r as Range: return contains(r.c, c) ? Empty() : Null()
    case let r as Plus: return Seq(der(c, r.r), Star(r.r))
    case let r as Opt: return der(c, r.r)
    case let r as Mult: return r.m == 0 ? Null() : Seq(der(c, r.r), Mult(r: r.r, n: r.n-1, m: r.m-1))
    case let r as Not: return Not(der(c, r.r))
    default: return r
    }
}

func ders(s: [Character], r:Rexp) -> Rexp {
    if s.isEmpty { return r }
    return ders(Array(s[1..<s.count]), simp(der(s[0], r)))
}

func matches(r: Rexp, s:String) -> Bool {
    return nullable(ders(Array(s), r))
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
    case let r as Mult: return 1 + count(r.r)
    default: return 1
    }
}

func ==(r1: Rexp, r2: Rexp) -> Bool {
    switch (r1, r2) {
    case is (Null, Null): return true
    case is (Empty, Empty): return true
    case let (r1 as String, r2 as String): return r1.description == r2.description
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
func ^(r: Rexp, p:[Int]) -> Rexp { return Mult(r: r, n: p[0], m: p[1])}

prefix func !(r: Rexp) -> Rexp { return Not(r) }

postfix operator * {}
postfix func *(r: Rexp) -> Rexp { return Star(r) }
postfix operator + {}
postfix func +(r: Rexp) -> Rexp { return Plus(r) }
postfix operator % {}
postfix func %(r: Rexp) -> Rexp { return Opt(r) }