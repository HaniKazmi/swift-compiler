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

let content = "{x23:=2+3-4/2;n:=10;minus1:=0;minus2:=1;temp:=0;zero:=0;while(n>zero)do{temp:=minus2;minus2:=minus1+minus2;minus1:=temp;n:=n-1};result:=minus2}"
Eval(content)
let startTime = CFAbsoluteTimeGetCurrent()

    println(tok(TOKEN, content))
    tokenise("test.txt")

let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
println("Time elapsed: \(timeElapsed) s")