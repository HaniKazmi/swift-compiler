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

func nullable(r: Rexp) -> Bool {
    switch r {
    case is Null:           return false
    case is Empty:          return true
    case is Char:           return false
    case let r as Alt:      return nullable(r.r1) || nullable(r.r2)
    case let r as Seq:      return nullable(r.r1) && nullable(r.r2)
    case is Star:           return true
    case is Chars:          return false
    case let r as Plus:     return nullable(r.r)
    case let r as Opt:      return true
    case let r as Ntimes:   return r.n == 0 ? true : nullable(r.r)
    case let r as Mult:     return r.n <= 0 ? true : nullable(r.r)
    case let r as Not:      return !nullable(r.r)
    case let r as Rec:      return nullable(r.r)
    default:                return false
    }
}

func der(c: Character, r: Rexp) -> Rexp {
    switch r {
    case is Null:           return Null()
    case is Empty:          return Null()
    case let r as Char:     return c == r.c ? Empty() : Null()
    case let r as Alt:      return Alt(der(c, r.r1), der(c, r.r2))
    case let r as Seq:      return nullable(r.r1) ?
        Alt(Seq(der(c, r.r1), r.r2), der(c, r.r2)) :
        Seq(der(c, r.r1), r.r2)
    case let r as Star:     return Seq(der(c, r.r), Star(r.r))
    case let r as Chars:    return contains(r.c, c) ? Empty() : Null()
    case let r as Plus:     return Seq(der(c, r.r), Star(r.r))
    case let r as Opt:      return der(c, r.r)
    case let r as Ntimes:   return r.n == 0 ? Null() : Seq(der(c, r.r), Ntimes(r.r, r.n-1))
    case let r as Mult:     return r.m == 0 ? Null() : Seq(der(c, r.r), Mult(r: r.r, n: r.n-1, m: r.m-1))
    case let r as Not:      return Not(der(c, r.r))
    case let r as Rec:      return der(c, r.r)
    default:                return r
    }
}

func ders(s: String, r:Rexp) -> Rexp {
    if s.isEmpty { return r }
    return ders(s.tail, simp(der(s.head, r)).0)
}

func matches(r: Rexp, s:String) -> Bool {
    return nullable(ders(s, r))
}

func simp(r: Rexp) -> (Rexp, Val -> Val) {
    func f_alt(f1: Val -> Val, f2: Val -> Val) -> Val -> Val {
        return {
            if let v = $0 as? left { return left(f1(v.v)) }
            else { let v = $0 as right; return right(f2(v.v)) }
        }
    }
    
    func f_seq(f1: Val -> Val, f2: Val -> Val) -> Val -> Val {
        return { let v = $0 as seq; return seq(f1(v.v1), f2(v.v2)) }
    }
    
    func f_error(f: Val = void()) -> Val -> Val {
        return { (v: Val) -> Val in void() }
    }
    
    func f_rec(f: Val -> Val) -> Val -> Val {
        return { let v = $0 as rec; return rec(v.x, f($0)) }
    }
    
    switch r {
    case let r as Alt:
        let ( (r1, f1), (r2, f2) ) = ( simp(r.r1), simp(r.r2) )
        switch (r1, r2) {
        case (is Null, _):          return ( r2, { right(f2($0)) } )
        case (_, is Null):          return ( r1, { left(f1($0)) } )
        case (_, _) where r1 == r2: return ( r1, { left(f1($0)) } )
        default:                    return ( Alt(r1, r2), f_alt(f1, f2) )
        }
        
    case let r as Seq:
        let ((r1, f1), (r2, f2)) = (simp(r.r1), simp(r.r2))
        switch (r1, r2) {
        case (is Null, _):          return ( Null(), f_error() )
        case (_, is Null):          return ( Null(), f_error() )
        case (is Empty, _):         return ( r2, { seq(f1(void()), f2($0)) } )
        case (_, is Empty):         return ( r1, { seq(f1($0), f2(void())) } )
        default:                    return ( Seq(r1, r2), f_seq(f1, f2) )
        }
        
    case let r as Rec:
        let (rs, f) = simp(r.r)
        return ( Rec(r.x, rs), f_rec(f) )
        
    default: return ( r, { (v: Val) -> Val in v } )
    }
}

func ==(r1: Rexp, r2: Rexp) -> Bool {
    switch (r1, r2) {
    case is (Null, Null): return true
    case is (Empty, Empty): return true
    case let (r1 as Char, r2 as Char):      return r1.c == r2.c
    case let (r1 as Alt, r2 as Alt):        return r1.r1 == r2.r1 && r1.r2 == r2.r2
    case let (r1 as Seq, r2 as Seq):        return r1.r1 == r2.r1 && r1.r2 == r2.r2
    case let (r1 as Opt, r2 as Opt):        return r1.r == r2.r
    case let (r1 as Star, r2 as Star):      return r1.r == r2.r
    case let (r1 as Chars, r2 as Chars):    return r1.c == r2.c
    case let (r1 as Plus, r2 as Plus):      return r1.r == r2.r
    case let (r1 as Rec, r2 as Rec):        return r1.r == r2.r
    default: return false
    }
}