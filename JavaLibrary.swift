//
//  JavaLibrary.swift
//  WhileCompiler
//
//  Created by Hani Kazmi on 09/12/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

let Header = header + wi_header + ws_header + ri_header + b_header
let Footer = end

let lRead = "invokestatic XXX/XXX/read()I"
let lWriteS = "invokestatic XXX/XXX/writes(Ljava/lang/String;)V"
let lWrite = "dup\n" +
"invokestatic XXX/XXX/write(I)V"

let header = ".class public XXX.XXX\n" +
    ".super java/lang/Object\n" +
    ".method public <init>()V\n" +
    "aload_0\n" +
    "invokenonvirtual java/lang/Object/<init>()V\n" +
    "return\n" +
".end method\n\n"

let wi_header = ".method public static write(I)V\n" +
    ".limit locals 5\n" +
    ".limit stack 5\n" +
    "iload 0\n" +
    "getstatic java/lang/System/out Ljava/io/PrintStream;\n" +
    "swap\n" +
    "invokevirtual java/io/PrintStream/println(I)V\n" +
    "return\n" +
".end method\n\n"

let ws_header = ".method public static writes(Ljava/lang/String;)V\n" +
    ".limit stack 2\n" +
    ".limit locals 2\n" +
    "getstatic java/lang/System/out Ljava/io/PrintStream; aload 0\n" +
    "invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n" +
    "return\n" +
".end method\n\n"

let ri_header = ".method public static read()I .limit locals 10\n" +
    ".limit stack 10\n" +
    "ldc 0\n" +
    "istore 1 ; this will hold our final integer Label1:\n" +
    "getstatic java/lang/System/in Ljava/io/InputStream;\n" +
    "invokevirtual java/io/InputStream/read()I\n" +
    "istore 2\n" +
    "iload 2\n" +
    
    "ldc 10 ; the newline delimiter isub\n" +
    "ifeq Label2\n" +
    "iload 2\n" +
    "ldc 32 ; the space delimiter isub\n" +
    "ifeq Label2\n" +
    "iload 2\n" +
    "ldc 48\n" +
    "isub\n" +
    "ldc 10 iload 1 imul\n" +
    "iadd\n" +
    "istore 1 goto Label1\n" +
    "Label2:\n" +
    ";when we come here we have our integer computed in Local Variable 1 iload 1\n" +
    "ireturn\n" +
".end method\n\n"

let b_header = ".method public static main([Ljava/lang/String;)V\n" +
        ".limit stack 5\n" +
".limit locals 100\n\n"

let end = "\nreturn\n" +
".end method\n"