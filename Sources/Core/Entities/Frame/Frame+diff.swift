//
//  Frame+diff.swift
//  video2mvb
//
//  Created by Onee Chan on 08.09.2023.
//

import Foundation

extension Frame {
    public func diff(_ frame: Frame) -> Frame.Diff {
        guard frame.chunks.count == chunks.count else {
            return Frame.Diff(updated: [])
        }
        let updatedChunks = frame.chunks.filter { chunk in
            let ourChunk = chunks[chunk.x * chunksY + chunk.y]
            return !ourChunk.isEqualTo(chunk)
        }
        return Frame.Diff(updated: updatedChunks)
    }
}
