//
//  helper.swift
//  SwiftRSA
//
//  Created by Kailun Wu on 4/28/15.
//  Copyright (c) 2015 Kailun Wu. All rights reserved.
//

import Foundation


// Shabby hash function resulting in one byte.
func h(r: [UInt8]) -> UInt8 {
    var result:UInt8 = 0
    for byte in r {
        result = result ^ byte
    }
    return result
}


// Convert bit array to byte array.
func bitsToBytes(bits: [Bit]) -> [UInt8] {
    let numBits = bits.count
    let numBytes = (numBits + 7)/8
    var bytes = [UInt8](count : numBytes, repeatedValue : 0)
    
    for (index, bit) in enumerate(bits) {
        if bit == .One {
            bytes[index / 8] += UInt8(1 << (7 - index % 8))
        }
    }
    return bytes
}


// Find the multiplicative inverse of r2 modular r1.
// Courtesy of introcs.cs.princeton.edu/java/78crypto/ExtendedEuclid.java.html
func extendedEuclidean(var r1: UInt32, var r2: UInt32) ->
    (UInt32, Int32, Int32) {
        println("    r1 = \(r1)    r2 = \(r2)")
        if r2 == 0 {
            return (r1, 1, 0)
        }
        let results = extendedEuclidean(r2, modUInt(r1, r2))
        return (results.0, results.2,
            Int32(results.1 - (Int32(r1) / Int32(r2)) * results.2))
}


// Modular for unsigned integer. Avoid using the default % operator.
func modUInt(number: UInt32, base: UInt32) -> UInt32 {
    return number - (number / base) * base
}


// Modular for signed integer. Avoid using the default % operator.
func modInt(number:Int32, base: UInt32) -> UInt32 {
    var temp = number
    while temp < 0 {
        temp += Int32(base)
    }
    return UInt32(temp) - (UInt32(temp) / base) * base
}


// Convert an integer to bit array.
func bitArray(number: UInt32) -> [Bit] {
    let length = Int(log2(Double(number)) + 1)
    var bits = [Bit](count: 32, repeatedValue: Bit(rawValue: 0)!)
    let binaryString = String(number, radix: 2)
    var i = length - 1
    for char in binaryString {
        if let bit = String(char).toInt() {
            bits[i] = Bit(rawValue: bit)!
        }
        i--
    }
    return bits
}


// Test conversion.
func testBitArray(number: UInt32) {
    let bits = bitArray(number)
    print("\(number) is\t")
    for bit in bits {
        if bit == Bit.One {
            print(1)
        } else {
            print(0)
        }
    }
    println()
}


func printBitArray(bits: [Bit]) {
    for i in 0...(count(bits) - 1) {
        if bits[count(bits) - 1 - i] == Bit.One {
            print("1")
        } else {
            print("0")
        }
    }
    println()
}

// Get the non-zero byte count in a byte array.
func nonZeroCount(bytes: [UInt8]) -> Int {
    var nonzerocount: Int = 0
    for byte in bytes {
        if byte != 0 {
            nonzerocount++
        } else {
            break
        }
    }
    return nonzerocount
}

// Use fast exponentiation to calculate power
func fastExponetiation(m: UInt32, x: [Bit], n: UInt32) -> UInt32 {
    logger()
    println("    fast exponentiation")
    var y:UInt32 = 1
    for var i = count(x) - 1; i >= 0; i-- {
        y = modUInt(y * y, n)
        print("    i = \(i)    x[i] = \(x[i])    squaring = \(y)")
        if x[i] == Bit(rawValue: 1) {
            y = modUInt(y * m, n)
            print("    multiplying = \(y)")
        }
        println()
    }
    println("    y = \(y)")
    return y
}


// Encrypt a message with a key e.
func encrypt(m: UInt32, n: UInt32, eBits: [Bit]) -> UInt32 {
    // Calculate m ^ e mod n.
    return fastExponetiation(m, eBits, n)
}


func decrypt(y: UInt32, n: UInt32, dBits: [Bit]) -> UInt32 {
    return fastExponetiation(y, dBits, n)
}


// Convert bits array to an integer.
func bitsToInt(bits: [Bit]) -> Int {
    var u: Int = 0
    for i in 0...(count(bits) - 1) {
        if bits[i] == Bit.One {
            u += Int(pow(Float(2), Float(i)))
        }
    }
    return u
}

