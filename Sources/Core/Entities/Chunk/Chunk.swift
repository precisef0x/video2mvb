//
//  Chunk.swift
//  video2mvb
//
//  Created by Onee Chan on 30.08.2023.
//

import Foundation

public final class Chunk {
    
    public var x = 0
    public var y = 0
    private let chunkSize: Int
    
    public lazy var pixels = Array(repeating: Pixel(red: 0, green: 0, blue: 0),
                                   count: chunkSize * chunkSize)
    
    public convenience init(size: Int,
                            x: Int,
                            y: Int) {
        self.init(size: size)
        self.x = x
        self.y = y
    }
    
    public init(size: Int) {
        self.chunkSize = size
    }
    
    public var asData: Data {
        var data = Data([UInt8(x), UInt8(y)])
        let pixelsData = pixels.reduce(into: Data()) { partialResult, pixel in
            partialResult.append(pixel.rgb565data)
        }
        data.append(pixelsData)
        return data
    }
}

extension Chunk {
    
    public func isEqualTo(_ chunk: Chunk) -> Bool {
        guard pixels.count == chunk.pixels.count else { return false }
        return !pixels.enumerated().contains { (index, pixel) in
            !pixel.isApproximatelyEqualTo(chunk.pixels[index])
        }
    }
    
    public func setPixel(_ pixel: Pixel,
                         x: Int,
                         y: Int) {
        guard x >= 0, x < chunkSize,
              y >= 0, y < chunkSize else { return }
        pixels[y * chunkSize + x] = pixel
    }
}
