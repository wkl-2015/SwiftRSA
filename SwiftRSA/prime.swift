//
//  prime.swift
//  SwiftRSA
//
//  Created by Kailun Wu on 4/28/15.
//  Copyright (c) 2015 Kailun Wu. All rights reserved.
//

import Foundation


// x is the array of bits representing n - 1, not n.
func primalityTest(a: UInt32, n: UInt32, x: [UInt8]) -> Bool {
    var y: UInt32 = 1
    for var i = x.count - 1; i >= 0; i-- {
        let z = y
        y = modUInt(y * y, n)
        if y == 1 && z != 1 && z != n - 1 {
            return false
        }
        if x[i] == 1 {
            y = modUInt(y * a, n)
        }
    }
    if y != 1 {
        return false
    } else {
        return true
    }
}


// Check if an integer is prime using Miller-Rabin.
func isPrime(number: UInt32, var x: [UInt8]) -> Bool {
    if number <= 1 {
        return false
    }
    if modUInt(number, 2) == 0 {
        return false
    }
    logger()
    var a: UInt32 = 0
    // Do Miller-Rabin test for 20 values of a.
    for k in 1...20 {
        a = modUInt(UInt32(arc4random()), number)
        while a == 0 {
            a = modUInt(UInt32(arc4random()), number)
        }
        // Compute bits array for (number - 1).
        // Since x is an odd number, only x[0] needs to be changed.
        x[0] = 0
        if (!primalityTest(a, number, x)) {
            println("    test on a = \(a):   n = \(number) not prime")
            return false
        }
        println("    test on a = \(a):   n = \(number) perhaps prime")
    }
    return true
}



// Compute a prime number by randomly choosing the 5 internal bits.
// For example: x = [1,1,1,0,0,0,1] forms 0b01000111
func randomPrime() -> UInt32 {
    var number: UInt32 = 1
    var rand: UInt32
    var x: [UInt8] = [1, 0, 0, 0, 0, 0, 1]
    while !isPrime(number, x) {
        logger()
        println("    generate 7-bit number")
        x = [1, 0, 0, 0, 0, 0, 1]
        var bits: UInt8 = 0b01000001
        for i in 1...5 {
            rand = arc4random()
            x[i] = UInt8(modUInt(rand,2))
            println("    rand = \(rand) -> bit x[\(i)] = \(x[i])")
            bits = bits | x[i] << UInt8(i)
        }
        number = UInt32(bits)
        println("    number = \(number) generated")
    }
    println("    number = \(number) verified as prime")
    return number
}