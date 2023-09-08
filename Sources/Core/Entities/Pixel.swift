//
//  Pixel.swift
//  video2mvb
//
//  Created by Onee Chan on 30.08.2023.
//

import Foundation

public struct Pixel {
    
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    
    private let thresholdRB: Int = 8 // ~5 bits for red and blue channels
    private let thresholdG: Int = 4 // ~6 bits for green
    
    public func isApproximatelyEqualTo(_ pixel: Pixel) -> Bool {
        let rDiff = abs(Int(red) - Int(pixel.red))
        let gDiff = abs(Int(green) - Int(pixel.green))
        let bDiff = abs(Int(blue) - Int(pixel.blue))
        return rDiff < thresholdRB && gDiff < thresholdG && bDiff < thresholdRB
    }
    
    public var rgb565: UInt16 {
        let r = UInt16(red & 0b11111000) << 8
        let g = UInt16(green & 0b11111100) << 3
        let b = UInt16(blue & 0b11111000) >> 3
        return r | g | b
    }
    
    public var rgb565data: Data {
        var value = rgb565.bigEndian
        return Data(bytes: &value, count: MemoryLayout<UInt16>.size)
    }
}
