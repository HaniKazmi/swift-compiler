//
//  Tokens.swift
//  Regex
//
//  Created by Hani Kazmi on 01/11/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

let allLetters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUWXYZ"
let allNums = "0123456789"
let allSym = "_.-€"
let allChars = allLetters + allNums + allSym

let CHAR = Chars(allLetters)
let DIGIT = Chars(allNums)

let KEYWORDS = "while" | "if" | "then" | "else" | "do" | "for" | "to" | "true" | "false" | "read" | "write" | "skip"
let OPERATORS = "+" | "-" | "*" | "%" | "/" | "==" | "!=" | ">" | "<" | ":=" | "&&" | "||"
let STRINGS = "\"" & CHAR* & "\""
let PARAN = "(" | ")" | "{" | "}"
let SEMI = /";"
let WHITE = (/" ")+ | "\n"
let IDENT = CHAR & (CHAR | DIGIT | "_")*
let NUM = DIGIT+

let TOKEN = (("keyword" ~ KEYWORDS) |
            ("operator" ~ OPERATORS ) |
            ("string" ~ STRINGS) |
            ("paran" ~ PARAN) |
            ("semi" ~ SEMI) |
            (WHITE) |
            ("ident" ~ IDENT) |
            ("num" ~ NUM))*