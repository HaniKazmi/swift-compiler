//
//  Helpers.swift
//  Regex
//
//  Created by Hani Kazmi on 08/11/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

extension Rexp: Printable {
    var description: String {
        switch self {
        case is Null:           return "Null"
        case is Empty:          return "Empty"
        case let r as Char:     return "Char(\"\(r.c)\")"
        case let r as Alt:      return "Alt(\(r.r1),\(r.r2))"
        case let r as Seq:      return "Seq(\(r.r1),\(r.r2))"
        case let r as Star:     return "Star(\(r.r))"
        case let r as Chars:    return "Chars(\"\(String(r.c))\")"
        case let r as Plus:     return "Plus(\(r.r))"
        case let r as Opt:      return "\(r.r)?"
        case let r as Ntimes:   return "Mult(\(r.r), \(r.n))"
        case let r as Mult:     return "Mult(\(r.r), \(r.n), \(r.m))"
        case let r as Not:      return "Not(\(r.r))"
        case let r as Rec:      return r.r.description
        default:                return "Error"
        }
    }
}

extension Val: Printable {
    var description: String {
        switch self {
        case is void:           return "Not matched"
        case let r as char:     return "\(r.c)"
        case let r as seq:      return "seq(\(r.v1), \(r.v2))"
        case let r as left:     return "left(\(r.v))"
        case let r as right:    return "right(\(r.v))"
        case let r as stars:    return "stars(\(r.vs))"
        case let r as rec:      return "\(r.x) : \(r.v)"
        default:                return "error"
        }
    }
}

extension String {
    subscript(index: Int) -> Character {
        return self[advance(self.startIndex, index)]
    }
    
    subscript(range: Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self[start..<end]
    }
    
    var count: Int { return self.utf16Count }
    var c: Character { return self[0] }
    var s: String { return self[1..<self.count] }
}

func count(r: Rexp) -> Int {
    switch r {
    case let r as BinaryRexp:   return 1 + count(r.r1) + count(r.r2)
    case let r as UnaryRexp:    return 1 + count(r.r)
    case let r as Ntimes:       return 1 + count(r.r)
    case let r as Mult:         return 1 + count(r.r)
    case let r as Not:          return count(r.r)
    case let r as Rec:          return count(r.r)
    default:                    return 1
    }
}

func stringToRexp(s: String) -> Rexp {
    return s.count == 1 ? Char(s.c) : Seq(Char(s.c), stringToRexp(s.s))
}

func |(r1: Rexp, r2: Rexp) -> Alt { return Alt(r1, r2) }
func |(r1: String, r2: String) -> Alt { return Alt(/r1, /r2) }
func |(r1: Rexp, r2: String) -> Alt { return Alt(r1, /r2) }
func |(r1: String, r2: Rexp) -> Alt { return Alt(/r1, r2) }

func &(r1: Rexp, r2: Rexp) -> Seq { return Seq(r1, r2) }
func &(r1: String, r2: String) -> Seq { return Seq(/r1, /r2) }
func &(r1: String, r2: Rexp) -> Seq { return Seq(/r1, r2) }
func &(r1: Rexp, r2: String) -> Seq { return Seq(r1, /r2) }

func ^(r: Rexp, p:[Int]) -> Mult { return Mult(r: r, n: p[0], m: p[1]) }
infix operator ~ { associativity left precedence 150}
func ~(x: String, r: Rexp) -> Rec { return Rec(x, r) }

prefix func !(r: Rexp) -> Not { return Not(r) }
prefix operator / {}
prefix func /(s: String) -> Rexp { return stringToRexp(s) }

postfix operator * {}
postfix func *(r: Rexp) -> Star { return Star(r) }
postfix operator + {}
postfix func +(r: Rexp) -> Plus { return Plus(r) }
postfix operator % {}
postfix func %(r: Rexp) -> Opt { return Opt(r) }
