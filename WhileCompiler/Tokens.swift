//
//  Tokens.swift
//  WhileCompiler
//
//  Created by Hani Kazmi on 01/11/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

let allLetters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUWXYZ"
let allNums = "0123456789"
let allSym = "_.-€"

let CHAR = Chars(allLetters)
let DIGIT = Chars(allNums)

let KEYWORDS    = "while" | "if" | "then" | "else" | "do" | "for" | "to" | "true" | "false" | "read" | "write" | "skip"
let OPERATORS   = "+" | "-" | "*" | "%" | "/" | "==" | "!=" | ">" | "<" | ":=" | "&&" | "||"
let STRINGS     = "\"" & CHAR* & "\""
let PAREN       = "(" | ")" | "{" | "}"
let SEMI: Rexp  = /";"
let WHITE       = (/" ")+ | "\n"
let IDENT       = CHAR & (CHAR | DIGIT | "_")*
let NUM         = DIGIT+

let TOKEN = (
    ("keyword"  ~   KEYWORDS  )   |
        ("operator" ~   OPERATORS )   |
        ("string"   ~   STRINGS   )   |
        ("paren"    ~   PAREN     )   |
        ("semi"     ~   SEMI      )   |
        (               WHITE     )   |
        ("ident"    ~   IDENT     )   |
        ("num"      ~   NUM       )   )*

protocol Token {}

struct T_SEMI: Token {}
struct T_PAREN: Token { let s: String }
struct T_STRING: Token { let s: String }
struct T_COMMENT: Token {}
struct T_ID: Token { let s: String }
struct T_OP: Token { let s: String }
struct T_NUM: Token { let s: String }
struct T_KWD: Token { let s: String }
struct T_ERR: Token {}

func ==(l: Token, r: Token) -> Bool {
    switch (l, r) {
    case let (l as T_SEMI,  r as T_SEMI):   return true
    case is  (T_COMMENT,    T_COMMENT):     return true
    case let (l as T_PAREN, r as T_PAREN):  return l.s == r.s
    case let (l as T_STRING, r as T_STRING):return l.s == r.s
    case let (l as T_ID,    r as T_ID):     return l.s == r.s
    case let (l as T_OP,    r as T_OP):     return l.s == r.s
    case let (l as T_NUM,   r as T_NUM):    return l.s == r.s
    case let (l as T_KWD,   r as T_KWD):    return l.s == r.s
    default:                                return false
    }
}

typealias LexRules = [String : (String) -> Token]
var lex_rules: LexRules = [
    "keyword"   : { (s) -> Token in T_KWD(s: s) },
    "ident"     : { (s) -> Token in T_ID(s: s) },
    "string"    : { (s) -> Token in T_STRING(s: s) },
    "operator"  : { (s) -> Token in T_OP(s: s) },
    "num"       : { (s) -> Token in T_NUM(s: s) },
    "semi"      : { (_) -> Token in T_SEMI() },
    "paren"     : { (s) -> Token in T_PAREN(s: s) } ]

func tokeniser(t: token, rs: LexRules = lex_rules) -> [Token]{
    return t.map { rs[$0.0]?($0.1) ?? T_ERR() }
}
