//
//  Rexp.swift
//  Regex
//
//  Created by Hani on 01/10/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

protocol Rexp {}

struct Null: Rexp {}
struct Empty: Rexp {}
struct Char: Rexp { let c: Character; init(_ c: Character) { self.c = c } }
struct Alt: Rexp { let r1: Rexp, r2: Rexp; init(_ r1: Rexp, _ r2: Rexp) { self.r1 = r1; self.r2 = r2 } }
struct Seq: Rexp { let r1: Rexp, r2: Rexp; init(_ r1: Rexp, _ r2: Rexp) { self.r1 = r1; self.r2 = r2 } }
struct Star: Rexp { let r: Rexp; init(_ r: Rexp) { self.r = r } }

struct Range: Rexp { let c: [Character]; init(_ c: String) { self.c = Array(c) } }
struct Plus: Rexp { let r: Rexp; init(_ r: Rexp) { self.r = r } }
struct Opt: Rexp { let r: Rexp; init(_ r: Rexp) { self.r = r } }
struct Multiple: Rexp { let r: Rexp, n: Int, m: Int }
struct Not: Rexp { let r: Rexp; init(_ r: Rexp) { self.r = r } }

func simp(r: Rexp) -> Rexp {
    switch r {
    case let r as Alt:
        switch (simp(r.r1), simp(r.r2)) {
        case (is Null, let r2): return r2
        case (let r1, is Null): return r1
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
        
    default: return r
    }
}

func + (left: Rexp, right: Rexp) -> Rexp {
    return Alt(left, right)
}

func & (left: Rexp, right: Rexp) -> Rexp {
    return Seq(left, right)
}

postfix operator * {}
postfix func * (star: Rexp) -> Rexp {
    return Star(star)
}

prefix func ! (r: Rexp) -> Rexp {
    return Not(r)
}

func nullable(r: Rexp) -> Bool {
    switch r {
    case is Null: return false
    case is Empty: return true
    case is Char: return false
    case let r as Alt: return nullable(r.r1) || nullable(r.r2)
    case let r as Seq: return nullable(r.r1) && nullable(r.r2)
    case is Star: return true
    case is Range: return false
    case let r as Plus: return nullable(r.r)
    case let r as Opt: return true
    case let r as Multiple: return r.n <= 0 ? true : false
    case let r as Not: return !nullable(r.r)
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
    case let r as Range: return contains(r.c, c) ? Empty() : Null()
    case let r as Plus: return Seq(der(c, r.r), Star(r.r))
    case let r as Opt: return der(c, r.r)
    case let r as Multiple: return r.m == 0 ? Null() : Seq(der(c, r.r), Multiple(r: r.r, n: r.n-1, m: r.m-1))
    case let r as Not: return Not(der(c, r.r))
    default: return r
    }
}

func ders(s: [Character], r:Rexp) -> Rexp {
    if s.isEmpty { return r }
    return ders(Array(s[1..<s.count]), der(s[0], r))
}

func matches(r: Rexp, s:String) -> Bool {
    return nullable(ders(Array(s), r))
}