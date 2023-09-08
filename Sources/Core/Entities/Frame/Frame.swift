//
//  Frame.swift
//  video2mvb
//
//  Created by Onee Chan on 30.08.2023.
//

import Foundation
import CoreGraphics

public final class Frame {
    
    public let chunksX: Int
    public let chunksY: Int
    public let chunkSize: Int
    
    public struct Diff {
        public let updated: [Chunk]
        
        public var asData: Data {
            var data = Data()
            
            if updated.count > 0,
               let compressedChunks = Utils.compressedDataFrom(updated.asData()) {
                var size = UInt16(compressedChunks.count).littleEndian
                data.append(Data(bytes: &size,
                                 count: MemoryLayout<UInt16>.size))
                data.append(compressedChunks)
            } else {
                var size = UInt16(0).littleEndian
                data.append(Data(bytes: &size,
                                 count: MemoryLayout<UInt16>.size))
            }
            
            return data
        }
    }
    
    private(set) var chunks = [Chunk]()
    
    init(chunksX: Int,
         chunksY: Int,
         chunkSize: Int) {
        self.chunksX = chunksX
        self.chunksY = chunksY
        self.chunkSize = chunkSize
        
        chunks.reserveCapacity(chunksX * chunksY)
        for x in 0..<chunksX {
            for y in 0..<chunksY {
                chunks.append(Chunk(size: chunkSize, x: x, y: y))
            }
        }
    }
    
    public func setChunk(_ chunk: Chunk) {
        let index = chunk.x * chunksY + chunk.y
        guard index < chunks.count else { return }
        chunks[index] = chunk
    }
}

extension Frame {
    public static func buildFrom(frame: CGImage,
                                 configuration: Configuration) -> Frame {
        let reader = PixelsReader(image: frame,
                                  chunkSize: configuration.chunkDimension)
        let frame = Frame(chunksX: configuration.chunksX,
                          chunksY: configuration.chunksY,
                          chunkSize: configuration.chunkDimension)
        
        for x in 0..<configuration.chunksX {
            for y in 0..<configuration.chunksY {
                frame.setChunk(reader.readChunkAt(chunkX: x,
                                                  chunkY: y))
            }
        }
        
        return frame
    }
}
