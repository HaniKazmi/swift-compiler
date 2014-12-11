//
//  Helpers.swift
//  WhileCompiler
//
//  Created by Hani Kazmi on 08/11/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation

// MARK: - Printable Protocol
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

extension Stmt: Printable {
    var description: String {
        switch self {
        case is Skip: return "Skip"
        case let t as If: return "If(\(t.a), \(t.bl1), \(t.bl2))"
        case let t as While: return "While(\(t.b), \(t.bl))"
        case let t as For: return "For(\(t.a), \(t.i), \(t.bl))"
        case let t as Assign: return "Assign(\(t.s), \(t.a))"
        case let t as Read: return "Read(\(t.s))"
        case let t as WriteS: return "Write(\(t.s))"
        case let t as Write: return "Write(\(t.s))"
        default: return ""
        }
    }
}

extension AExp: Printable {
    var description: String {
        switch self {
        case let t as Var: return "Var(\(t.s))"
        case let t as Num: return "Num(\(t.i))"
        case let t as Aop: return "Aop(\(t.o), \(t.a1), \(t.a2))"
        default: return ""
        }
    }
}

extension BExp: Printable {
    var description: String {
        switch self {
        case is True: return "True"
        case is False: return "False"
        case let t as Bop: return "Bop(\(t.o), \(t.a1), \(t.a2))"
        default: return ""
        }
    }
}

// MARK: - Extensions
extension String {
    subscript(index: Int) -> Character {
        return self[advance(self.startIndex, index)]
    }
    
    /// Returns the substring from the given range
    subscript(range: Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self[start..<end]
    }
    
    var count: Int { return self.utf16Count }
    /// Returns the first character
    var head: Character { return self[0] }
    /// Returns the original string minus the first character
    var tail: String { return self[1..<self.count] }
}

extension Array {
    /// Returns the original array minus the first element
    var tail: [T] {
        return Array(self[1..<count])
    }
}

// MARK: - Helper functions
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

/// Returns a closure which is only evaluated when needed
func lazy<I, T>(p: () -> I -> T) -> I -> T {
    return  { p()($0) }
}

/// Reads a line from stdin
func readln() -> String {
    let standardInput = NSFileHandle.fileHandleWithStandardInput()
    let data = NSString(data: standardInput.availableData, encoding:NSUTF8StringEncoding)!
    return data.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
}

// Opens a file and returns it as a String
func readfile(path: String) -> String {
    return String(contentsOfFile: path)!
}

/// Write a string to a file
func writefile(file: String, path: String) {
    file.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
}

func execJasmin(path: String) {
    system("java -jar jasmin.jar \(path).j")
    system("java \(path)/\(path)")
}

// MARK: - Custom Operators
infix operator ~ { associativity left precedence 150 }
infix operator ==> { precedence 140 }
prefix operator / {}
postfix operator * {}
postfix operator + {}
postfix operator % {}
