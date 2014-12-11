//
//  main.swift
//  WhileCompiler
//
//  Created by Hani on 30/09/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation

let pr = Compile(tokeniser(tok("z := 7; y:= 0; for x := 4 + 1 upto z do { y := y + 3 }; write y")))
println(pr)
//compile_file()