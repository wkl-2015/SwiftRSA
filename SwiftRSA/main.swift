//
//  main.swift
//  SwiftRSA
//
//  Created by Kailun Wu on 4/25/15.
//  Copyright (c) 2015 Kailun Wu. All rights reserved.
//
//
//  main.swift
//  SwiftRSA
//
//  Created by Kailun Wu on 4/25/15.
//  Copyright (c) 2015 Kailun Wu. All rights reserved.
//

import Foundation

var lineCount = 0

// Maintain the line count.
func logger() {
    lineCount++
    println("\(lineCount)")
}


// Create an RSA public/private key pair.
func createRSA() -> RSA {
    var rsa = RSA(n: 0, e: 0, d: 0, nBits:[], eBits: [], dBits: [])
    // Generate two random primes.
    var p = randomPrime()
    var q = randomPrime()
    while p == q {
        q = randomPrime()
    }
    rsa.n = p * q
    let phi_n = (p - 1) * (q - 1)
    println("    p = \(p)    q = \(q)    n = \(rsa.n)    phi_n = \(phi_n)")
    // Generate e that's relatively prime with phi_n.
    for i in 3...(phi_n - 1) {
        logger()
        println("    verify e = \(i) with Extended Euclidean")
        let result = extendedEuclidean(phi_n, i)
        println("    i = \(i)\t divisor = \(result.0)\t s = \(result.1)\t t = \(result.2)")
        if result.0 == 1 {
            rsa.e = i
            // Find the multiplicative inverse of e as the private key d.
            println("    divisor = 1 => e is relative prime with phi_n")
            logger()
            println("    d = \(result.2) is the multiplicative inverse of e")
            rsa.d = modInt(result.2, phi_n)
            break;
        }
        println("    divisor = \(result.0) != 1 => e is not relative prime with phi_n")
    }
    // Save n, e and d to bit array.
    logger()
    println("    p = \(p)\n    p = \(String(p, radix: 2))")
    println("    q = \(q)\n    q = \(String(q, radix: 2))")
    rsa.nBits = bitArray(rsa.n)
    rsa.eBits = bitArray(rsa.e)
    rsa.dBits = bitArray(rsa.d)
    print("    n = \(rsa.n)\n    n = ")
    printBitArray(rsa.nBits)
    print("    e = \(rsa.e)\n    e = ")
    printBitArray(rsa.eBits)
    print("    d = \(rsa.d)\n    d = ")
    printBitArray(rsa.dBits)
    return rsa
}




// Create a digital certificate as a 14 bytes array.
func digitalCertificate(trent: RSA, alice: RSA, name: String) -> (r:[UInt8], s: UInt32) {
    var r = [UInt8](count: 14, repeatedValue: 0)
    // Store the name in r[0...5].
    let nameBytes = [UInt8](name.utf8)
    for i in 0...(count(nameBytes) - 1) {
        r[i] = nameBytes[i]
    }
    // Store n:UInt32 in r[6...9].
    let n_bytes = bitsToBytes(alice.nBits)
    // Omit the trailing zeros in the byte array.
    var nonzeroCount = nonZeroCount(n_bytes)
    for i in (10 - nonzeroCount)...9 {
        r[i] = n_bytes[i - 10 + nonzeroCount]
    }
    // Store e:UInt32 in r[10...13].
    let e_bytes = bitsToBytes(alice.eBits)
    // Omit the trailing zeros in the byte array.
    nonzeroCount = nonZeroCount(e_bytes)
    for i in (14 - nonzeroCount)...13 {
        r[i] = e_bytes[i - 14 + nonzeroCount]
    }
    let hash = h(r)
    // Trent sign the hash by decrypt it with Trent's private key.
    let s: UInt32 = decrypt(UInt32(hash), trent.n, trent.dBits)
    // Show r, h(r) and s as bits
    logger()
    println("    r = \(r)")
    println("    h(r) = \(String(h(r), radix: 2))")
    println("    s = \(String(s, radix: 2))")
    // Show h(r), s as integers.
    logger()
    println("    h(r) = \(hash)")
    println("    s = \(s)")
    return (r, s)
}





// Find a large number u < n.  nBits = 11010001000101000000000000000000
func findU(nBits: [Bit]) -> [Bit] {
    var k = 31
    for i in 0...31 {
        if nBits[31 - i] == Bit(rawValue: 1) {
            k = 31 - i
            break
        }
    }
    var uBits = [Bit](count: 31, repeatedValue: Bit(rawValue: 0)!)
    for i in 0...(k - 1) {
        if modUInt(arc4random(), 2) == 1 {
            uBits[i] = Bit.One
        }
    }
    let u = bitsToBytes(uBits)
    logger()
    println("    k = \(k)\n    u = \(u)")
    return uBits
}


// Test the final project.
func testProject() {
    // Generate the public/private keys for Trent and Alice.
    let rsaTrent = createRSA()
    let rsaAlice = createRSA()
    let certificate = digitalCertificate(rsaTrent, rsaAlice, "Alice")
    // Bob choose u.
    let uBits = findU(rsaAlice.nBits)
    let uBytes = bitsToBytes(uBits)
    logger()
    print("    uBits = ")
    printBitArray(uBits)
    let hash_u = h(uBytes)

    // Try to verify Alice.
    let v = decrypt(UInt32(hash_u), rsaAlice.n, rsaAlice.dBits)
    let w = encrypt(v, rsaAlice.n, rsaAlice.eBits)
    logger()
    println("    u = \(bitsToBytes(uBits))")
    print("    u = ")
    printBitArray(uBits)
    println("    h(u) = \(hash_u)")
    println("    h(u) = \(String(hash_u, radix: 2))")
    println("    v = \(v)")
    println("    v = \(String(v, radix: 2))")
    println("    compare E(v, e) = \(w) with h(u) = \(hash_u) to verify Alice")
}


// Run the test.
testProject()
