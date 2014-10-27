//
//  main.swift
//  Regex
//
//  Created by Hani on 30/09/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation

// Helper functions
func printR(r: Rexp, s: String) {
    println("\(s): \(matches(r, s))")
}

infix operator ^ { precedence 160 }

let allLetters = "abcdefghijklmnopqrstuvwxyz"
let allNums = "0123456789"
let allSym = "_.-€"
let allChars = allLetters + allNums + allSym


// Question 3
let e = Range(allChars)+ & "@" & Range(allLetters+"."+"-")+ & "." & (Range(allLetters+".")^[2,6])
printR(e, "hani.kazmi@kcl.ac.uk")
println(ders(Array("hani.kazmi@kcl.ac.uk"), e))


// Question 4
let r = "/" & "*" & !(Range("abcdefghijklmnopqrstuvqxyz")* & "*" & "/" & Range("abcdefghijklmnopqrstuvqxyz")*) & "*" & "/"

printR(r, "/**/")
printR(r, "/*foobar*/")
printR(r, "/*test*/test*/")
printR(r, "/*test*/*test*/")

// Question 5
let r1 = "a" & "a" & "a"
let r2 = "a"^[19,19] & "a"%

let a1 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
let a2 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
let a3 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

printR((r1+)+, a1)
printR((r1+)+, a2)
printR((r1+)+, a3)

printR((r2+)+, a1)
printR((r2+)+, a2)
printR((r2+)+, a3)
