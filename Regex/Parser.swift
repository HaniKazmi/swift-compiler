//
//  Parser.swift
//  Regex
//
//  Created by Hani Kazmi on 09/11/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation

typealias C = CollectionType

func CharParse(c: Character) -> String ->[(Character, String)] {
    return { $0.c == c ? [($0.c, $0.s)] : [] }
}

func AltParse<I: C, T>(p: I -> [(T, I)], q: I -> [(T, I)]) -> I -> [(T, I)] {
    return { p($0) + q($0) }
}

func SeqParse<I: C, T, S>(p: I -> [(T, I)], q: I -> [(S, I)]) -> I -> [((T, S), I)]
{
    return {
        var acc = [((T, S), I)]()
        for (head1, tail1) in p($0) {
            for (head2, tail2) in q(tail1) {
                acc += [((head1, head2), tail2)]
            }
        }
        return acc
    }
}

func FunParse<I: C, T, S>(p: I -> [(T, I)], f: T -> S) -> I -> [(S, I)] {
    return {
        var acc = [(S, I)]()
        for (head, tail) in p($0){
            acc += [(f(head), tail)]
        }
        return acc
    }
}

func StringParse(s: String) -> String -> [(String, String)] {
    return {
        if s.count > $0.count { return [] }
        let (prefix, suffix) = ($0[0..<s.count], $0[s.count..<$0.count])
        return prefix == s ? [(prefix, suffix)] : []
    }
}

func NumParse() -> String -> [(Int, String)] {
    return {
        let reg = "[0-9]+"
        if let match = $0.rangeOfString(reg, options: .RegularExpressionSearch) {
            if match.startIndex == $0.startIndex {
                let dis: Int = distance($0.startIndex, match.endIndex)
                return [($0[0..<dis].toInt()!, $0[dis..<$0.count])]
            }
        }
        return []
    }
}

func IdParser() -> String -> [(String, String)] {
    return {
        let reg = "[a-z][a-z0-9]*"
        if let match = $0.rangeOfString(reg, options: .RegularExpressionSearch) {
            if match.startIndex == $0.startIndex {
                let dis: Int = distance($0.startIndex, match.endIndex)
                return [($0[0..<dis], $0[dis..<$0.count])]
            }
        }
        return []
    }
}

func lazy<I, T>(p: () -> I -> T) -> I -> T {
    return  { p()($0) }
}

func satisfy<I: C, T>(p: [(T, I)]) -> [T] {
    return p.filter { isEmpty($0.1) }.map { $0.0 }
}

func ||<I: C, T>(p: I -> [(T, I)], q: I -> [(T, I)]) -> I -> [(T, I)] { return AltParse(p, q) }

infix operator ==> {}
func ==><I: C, T, S>(p: I -> [(T, I)], f: T -> S) -> I -> [(S, I)]  { return FunParse(p, f) }

func ~<I: C, T, S>(p: I -> [(T, I)], q: I -> [(S, I)]) -> I -> [((T, S), I)] { return SeqParse(p, q) }

prefix func /(s: String) -> (String) -> [(String, String)] { return StringParse(s) }

func E() -> (String) -> [(Int, String)] {
   return  (lazy(T) ~ /"+" ~ lazy(E) ==> { let ((x, y), z) = $0; return x+z } ) || lazy(T)
}

func T() -> (String) -> [(Int, String)] {
    return (lazy(F) ~ /"*" ~ lazy(T) ==> { let ((x, y), z) = $0; return x*z } ) || lazy(F)
}

func F() -> (String) -> [(Int, String)] {
    return (/"(" ~ lazy(E) ~ /")" ==> { let ((x, y), z) = $0; return y } ) || NumParse()
}

