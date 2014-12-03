//
//  main.swift
//  Regex
//
//  Created by Hani on 30/09/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation

let dir = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String])![0]

func tokenise(path: String) -> token {
    let path = dir.stringByAppendingPathComponent(path);
    let content = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
    return tok(TOKEN, content)
}

let x = CharParse("a")
let y = CharParse("b")
let z = AltParse(x, y)
println(z("ca"))
println(x("asdfgh"))
let a = SeqParse(z, y)
let s = IdParser()
println(s("h2ello"))
println(a("bbassas"))

Eval("{n:=10/0}")
let startTime = CFAbsoluteTimeGetCurrent()

for var x=0; x<100; x++ {
    tokenise("test1.txt")
    tokenise("test.txt")
}

let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
println("Time elapsed: \(timeElapsed) s")