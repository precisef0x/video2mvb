//
//  PixelsReader.swift
//  video2mvb
//
//  Created by Onee Chan on 30.08.2023.
//

import Foundation
import CoreGraphics

public final class PixelsReader {
    private var pixelsData: CFData?
    private var data: UnsafePointer<UInt8>?
    
    private let chunkSize: Int
    private let frameWidth: Int
    private let frameHeight: Int
    
    public init(image: CGImage,
                chunkSize: Int) {
        self.chunkSize = chunkSize
        self.frameWidth = image.width
        self.frameHeight = image.height
        
        if let pixelsData = image.dataProvider?.data {
            self.data = CFDataGetBytePtr(pixelsData)
            self.pixelsData = pixelsData
        }
    }
    
    public func readChunkAt(chunkX: Int, chunkY: Int) -> Chunk {
        let result = Chunk(size: chunkSize,
                           x: chunkX,
                           y: chunkY)
        
        guard chunkX >= 0, chunkY >= 0,
              chunkSize * (chunkX + 1) <= frameWidth,
              chunkSize * (chunkY + 1) <= frameHeight,
              let data = self.data else { return result }
        
        for y in 0..<chunkSize {
            let rowStart = ((chunkY * chunkSize + y) * frameWidth
                            + chunkX * chunkSize) * 4
            let rowEnd = rowStart + chunkSize * 4
            let count = rowEnd - rowStart
            let rowSlice = UnsafeBufferPointer(start: data + rowStart, count: count)
            
            for x in 0..<chunkSize {
                let pixelStart = x * 4
                let red = rowSlice[pixelStart]
                let green = rowSlice[pixelStart + 1]
                let blue = rowSlice[pixelStart + 2]
                result.setPixel(Pixel(red: red, green: green, blue: blue),
                                x: x, y: y)
            }
        }
        
        return result
    }
}
