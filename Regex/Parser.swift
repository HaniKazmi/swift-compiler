//
//  Parser.swift
//  Regex
//
//  Created by Hani Kazmi on 09/11/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation
//    class Parser<I, T> {
//        func parse(ts: I) -> [(T, I)] { return [] }
//
////        func parse_all(ts: I) -> [(T, I)] {
////            return parse(ts).filter { isEmpty($0.1) }
////        }
//    }
//
//    class CharParser<I, T> : Parser<[Character], Character> {
//        let c: Character
//
//        init(c: Character) { self.c = c }
//
//        override func parse(ts: [Character]) -> [(Character, [Character])] {
//            return ts[0] == c ? [(ts[0], Array(ts[1..<ts.count]))] : []
//        }
//    }
//
//    class AltParser<I, T> : Parser<I, T> {
//        let p: Parser<I, T>
//        let q: Parser<I, T>
//
//        init(p: Parser<I, T>, q: Parser<I,T>) {
//            self.p = p
//            self.q = q
//        }
//
//        override func parse(ts: I) -> [(T, I)] {
//            println(ts)
//            return p.parse(ts)
//        }
//    }

class Parser<I, T> {
    func parse(ts: I) -> [(T, I)] { return [] }
    
    //    func parse_all(ts: I) -> [(T, I)] {
    //        return parse(ts).filter { isEmpty($0.1) }
    //    }
}

class charParser<I, T>: Parser<String, Character> {
    let c: Character
    
    init(c: Character) { self.c = c }
    
    override func parse(ts: String) -> [(Character, String)] {
        return ts.c == c ? [(ts[0], ts.s)] : []
    }
}
typealias CharParser = charParser<String, Character>

func CharParse(c: Character) -> (String) ->[(Character, String)] {
    return { $0.c == c ? [($0[0], $0.s)] : [] }
}

func AltParser<I, T>(p: I -> [(T, I)], q: I -> [(T, I)]) -> (I) -> [(T, I)] {
    return { p($0) + q($0) }
}

func SeqParse<I, T, S>(p: I -> [(T, I)], q: I -> [(S, I)]) -> (I) -> [((T, S), I)]
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

func FunParse<I, T, S>(p: I -> [(T, I)], f: T -> S) -> (I) -> [(S, I)] {
    return {
        var acc = [(S, I)]()
        for (head, tail) in p($0){
            acc += [(f(head), tail)]
        }
        return acc
    }
}

func StringParse(s: String) -> (String) -> [(String, String)] {
    return {
        if s.count > $0.count { return [] }
        let (prefix, suffix) = ($0[0..<s.count], $0[s.count..<$0.count])
        return prefix == s ? [(prefix, suffix)] : []
    }
}

func NumParse() -> (String) -> [(Int, String)] {
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
//class AltParser<I: CollectionType, T>: Parser<I, T> {
//    let p: I -> [(T, I)]
//    let q: I -> [(T, I)]
//
//    init(p: I -> [(T, I)], q: I -> [(T, I)]) { self.p = p; self.q = q }
//
//    override func parse(ts: I) -> [(T, I)] {
//        return p(ts) + q(ts)
//    }
//}
//
//class SeqParser<I: CollectionType, T, S>: Parser<I, (T, S)> {
//    let p: I -> [(T, I)]
//    let q: I -> [(S, I)]
//
//    init(p: I -> [(T, I)], q: I -> [(S, I)]) { self.p = p; self.q = q }
//
//    override func parse(ts: I) -> [((T, S), I)] {
//        var acc = [((T, S), I)]()
//        for (head1, tail1) in p(ts) {
//            for (head2, tail2) in q(tail1) {
//                acc += [((head1, head2), tail2)]
//            }
//        }
//        return acc
//    }
//}
//
//class SeqParser2<I: CollectionType, T, S>: Parser<I, (T, S)> {
//    let p: Parser<I, T>
//    let q: Parser<I, S>
//
//    init(p: Parser<I, T>, q: Parser<I, S>) { self.p = p; self.q = q }
//
//    override func parse(ts: I) -> [((T, S), I)] {
//        var acc = [((T, S), I)]()
//        for (head1, tail1) in p.parse(ts) {
//            for (head2, tail2) in q.parse(tail1) {
//                acc += [((head1, head2), tail2)]
//            }
//        }
//        return acc
//    }
//}
//
//class FunParser<I: CollectionType, T, S>: Parser<I, S> {
//    let p: I -> [(T, I)]
//    let f: T -> S
//
//    init(p: I -> [(T, I)], f: T -> S) { self.p = p; self.f = f }
//
//    override func parse(sb: I) -> [(S, I)] {
//        var acc = [(S, I)]()
//        for (head, tail) in p(sb){
//            acc += [(f(head), tail)]
//        }
//        return acc
//    }
//}
//
//class stringParser<I, T>: Parser<String, String> {
//    let s: String
//
//    init(s: String) { self.s = s }
//
//    override func parse(sb: String) -> [(String, String)] {
//        let (prefix, suffix) = (sb[0..<s.count], sb[s.count..<sb.count])
//        return prefix == s ? [(prefix, suffix)] : []
//    }
//}
//typealias StringParser = stringParser<String, String>
//
//
//class numParser<I, T>: Parser<String, Int> {
//    override func parse(sb: String) -> [(Int, String)] {
//        let reg = "[0-9]+"
//        if let match = sb.rangeOfString(reg, options: .RegularExpressionSearch) {
//            if match.startIndex == sb.startIndex {
//                let dis: Int = distance(sb.startIndex, match.endIndex)
//                return [(sb[0..<dis].toInt()!, sb[dis..<sb.count])]
//            }
//        }
//        return []
//    }
//}
//typealias NumParser = numParser<String, AnyObject>
//

func lazy<I, T>(p: () -> (I) -> [(T,I)]) -> (I) -> [(T, I)] {
    return  { p()($0) }
}

func E() -> (String) -> [(Int, String)] {
   return  (lazy(T) ~ StringParse("+") ~ lazy(E) ==> { let ((x, y), z) = $0; return x+z } ) || lazy(T)
}

func T() -> (String) -> [(Int, String)] {
    return (lazy(F) ~ StringParse("*") ~ lazy(T) ==> { let ((x, y), z) = $0; return x*z } ) || lazy(F)
}

func F() -> (String) -> [(Int, String)] {
    return (StringParse("(") ~ lazy(E) ~ StringParse(")") ==> { let ((x, y), z) = $0; return y } ) || NumParse()
}

func ||<I, T>(p: I -> [(T, I)], q: I -> [(T, I)]) -> I -> [(T, I)] { return AltParser(p, q) }

infix operator ==> {associativity left}
func ==><I, T, S>(p: I -> [(T, I)], f: T -> S) -> I -> [(S, I)]  { return FunParse(p, f) }

func ~<I, T, S>(p: I -> [(T, I)], q: I -> [(S, I)]) -> I -> [((T, S), I)] { return SeqParse(p, q) }

