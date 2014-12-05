//
//  main.swift
//  WhileCompiler
//
//  Created by Hani on 30/09/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation

let dir = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String])![0]

func tokenise(path: String) -> [Token] {
    let path = dir.stringByAppendingPathComponent(path);
    let content = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
    return tokeniser(tok(content))
}

let startTime = CFAbsoluteTimeGetCurrent()
Eval(tokenise("test.txt"))
let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
println("Time elapsed: \(timeElapsed) s")