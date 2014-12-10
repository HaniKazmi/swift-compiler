//
//  main.swift
//  WhileCompiler
//
//  Created by Hani on 30/09/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation

let dir = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String])![0]

let startTime = CFAbsoluteTimeGetCurrent()
compile_file(path: "/Users/hanikazmi/Documents/test.txt")
let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
println("Time elapsed: \(timeElapsed) s")