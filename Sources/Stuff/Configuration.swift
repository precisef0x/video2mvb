//
//  Config.swift
//  video2mvb
//
//  Created by Onee Chan on 07.09.2023.
//

import Foundation

public class Configuration {
    
    var inputFilename: String = ""
    var outputFilename: String = ""
    var chunkDimension: Int = 40
    var frameWidth: Int = 160
    var frameHeight: Int = 80
    var targetFPS: Int = 15
    var skipFrames: Int = 0
    
    lazy var frameSize: CGSize = {
        CGSize(width: CGFloat(frameWidth),
               height: CGFloat(frameHeight))
    }()
    
    lazy var frameRatio = {
        CGFloat(frameWidth) / CGFloat(frameHeight)
    }()
    
    lazy var chunksX = {
        frameWidth / chunkDimension
    }()
    
    lazy var chunksY = {
        frameHeight / chunkDimension
    }()
    
    public init() { }
}

// MARK: - Public methods
extension Configuration {
    
    public func runVerificationDialog() {
        Log.log("[i] Configuration: ")
        let descriptions = [
            ("input filename", inputFilename),
            ("output filename", outputFilename),
            ("chunk size", "\(chunkDimension)"),
            ("target frame size", "\(frameWidth) x \(frameHeight)"),
            ("target FPS", "\(targetFPS)"),
            skipFrames > 0 ? ("Skip frames", "\(skipFrames)") : nil
        ].compactMap { $0 }
        
        for (key, value) in descriptions {
            Log.log("  - \(key): \(value)", .info)
        }
        
        Log.log("\n[!] Proceed? (Y)/n: ", .info, terminator: "")
        guard let input = readLine()?.lowercased(),
              !["N", "n", "No", "no"].contains(input) else {
            Log.log("[i] See you!")
            exit(0)
        }
    }
    
    public func performInitialChecks() {
        Utils.performInitialChecks(configuration: self)
    }
    
    public func updateWith(inputFilename: String,
                           outputFilename: String,
                           chunkDimension: Int?,
                           width: Int?,
                           height: Int?,
                           fps: Int?,
                           skip: Int?) {
        self.inputFilename = inputFilename
        self.outputFilename = outputFilename
        
        if let chunkDimension { self.chunkDimension = chunkDimension }
        if let width { self.frameWidth = width }
        if let height { self.frameHeight = height }
        if let fps { self.targetFPS = fps }
        if let skip { self.skipFrames = skip }
    }
}
