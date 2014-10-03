//
//  main.swift
//  Regex
//
//  Created by Hani on 30/09/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation

let r = Char("/") & Char("*") & !(Range("abcdefghijklmnopqrstuvqxyz")* & Char("*") & Char("/") & Range("abcdefghijklmnopqrstuvqxyz")*) & Char("*") & Char("/")
let x = matches(r, "/*test*/test*/")
println(x)