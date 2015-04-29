//
//  RSA.swift
//  SwiftRSA
//
//  Created by Kailun Wu on 4/28/15.
//  Copyright (c) 2015 Kailun Wu. All rights reserved.
//

import Foundation

struct RSA {
    var n: UInt32
    var e: UInt32
    var d: UInt32
    var nBits: [Bit]
    var eBits: [Bit]
    var dBits: [Bit]
}
