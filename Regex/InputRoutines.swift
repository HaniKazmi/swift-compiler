//
//  InputRoutines.swift
//  Regex
//
//  Created by Hani on 01/10/2014.
//  Copyright (c) 2014 Hani. All rights reserved.
//

import Foundation

func getString() -> NSString {
    let data = NSFileHandle.fileHandleWithStandardInput().availableData
    return NSString(data: data, encoding: NSUTF8StringEncoding)
}