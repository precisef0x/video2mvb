//
//  main.swift
//  video2mvb
//
//  Created by Onee Chan on 06.09.2023.
//

import Foundation
import ArgumentParser

var config = Configuration()

struct CommandConfig: ParsableCommand {
    
    // Parse command-line arguments
    @Option(name: .shortAndLong, help: "Input file name")
    var input: String
    
    @Option(name: .shortAndLong, help: "Output file name")
    var output: String
    
    @Option(name: .long, help: "Chunk size (dimension of a square chunk)")
    var cs: Int?
    
    @Option(name: .long, help: "Target frame width")
    var width: Int?
    
    @Option(name: .long, help: "Target frame height")
    var height: Int?
    
    @Option(name: .long, help: "Target frames per second")
    var fps: Int?
    
    @Option(name: .shortAndLong, help: "Skip every (1 + skip)-th frame; default = 0")
    var skip: Int?
    
    static var _commandName = "video2mvb"
    
    func run() {
        // Update the configuration with parsed arguments
        config.updateWith(
            inputFilename: input,
            outputFilename: output,
            chunkDimension: cs,
            width: width,
            height: height,
            fps: fps,
            skip: skip
        )
    }
}
CommandConfig.main()

// Verify the configuration and perform initial system and file checks
config.runVerificationDialog()
config.performInitialChecks()

// Encode!
let encoder = Encoder(configuration: config)
encoder.loadVideo()
encoder.loadVideoTrack()
encoder.readVideoTrack()
encoder.startEncoding()
