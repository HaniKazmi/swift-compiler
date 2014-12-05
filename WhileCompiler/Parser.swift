//
//  Parser.swift
//  WhileCompiler
//
//  Created by Hani Kazmi on 09/11/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation

typealias C = CollectionType

func CharParse(c: Character) -> String ->[(Character, String)] {
    return { $0.head == c ? [($0.head, $0.tail)] : [] }
}

func AltParse<I: C, T>(p: I -> [(T, I)], q: I -> [(T, I)]) -> I -> [(T, I)] {
    return { p($0) + q($0) }
}

func SeqParse<I: C, T, S>(p: I -> [(T, I)], q: I -> [(S, I)]) -> I -> [((T, S), I)] {
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

func TokParser(tok: Token) -> [Token] -> [(Token, [Token])] {
    return {
        if let t = $0.first {
            return t == tok ? [(t, $0.tail)] : []
        }
        return []
    }
}

func IdParser() -> [Token] -> [(String, [Token])] {
    return {
        if let t = $0.first as? T_ID {
            return [(t.s, $0.tail)]
        }
        return []
    }
}

func NumParser() -> [Token] -> [(Int, [Token])] {
    return {
        if let t = $0.first as? T_NUM {
            return [(t.s.toInt()!, $0.tail)]
        }
        return []
    }
}

func StringParser() -> [Token] -> [(String, [Token])] {
    return {
        if let t = $0.first as? T_STRING {
            return [(t.s, $0.tail)]
        }
        return []
    }
}

func StringParse(s: String) -> String -> [(String, String)] {
    return {
        if s.count > $0.count { return [] }
        let (prefix, suffix) = ($0[0..<s.count], $0[s.count..<$0.count])
        return prefix == s ? [(prefix, suffix)] : []
    }
}

func StringNumParse() -> String -> [(Int, String)] {
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

func StringIdParser() -> String -> [(String, String)] {
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

func satisfy<I: C, T>(p: [(T, I)]) -> T {
    return p.filter { isEmpty($0.1) }.map { $0.0 }.first!
}

func ||<I: C, T>(p: I -> [(T, I)], q: I -> [(T, I)]) -> I -> [(T, I)] { return AltParse(p, q) }
func ==><I: C, T, S>(p: I -> [(T, I)], f: T -> S) -> I -> [(S, I)]  { return FunParse(p, f) }
func ~<I: C, T, S>(p: I -> [(T, I)], q: I -> [(S, I)]) -> I -> [((T, S), I)] { return SeqParse(p, q) }

prefix func /(s: String) -> (String) -> [(String, String)] { return StringParse(s) }
prefix func /(tok: Token) -> ([Token]) -> [(Token, [Token])] { return TokParser(tok) }
