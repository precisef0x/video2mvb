//
//  stuff.swift
//  video2mvb
//
//  Created by Onee Chan on 06.09.2023.
//

import Foundation
import CoreGraphics
import zlib

public final class Utils {
    
    public static func execute(_ command: String) -> (Bool, String) {
        let process = Process()
        process.launchPath = "/bin/sh"
        process.environment = ProcessInfo.processInfo.environment
        process.arguments = ["-c", command]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            process.launch()
            process.waitUntilExit()
            group.leave()
        }
        group.wait()
        
        let success = process.terminationStatus == 0
        let output = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(data: output,
                                  encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        return (success, outputString)
    }
    
    public static func performInitialChecks(configuration: Configuration) {
        ffmpegInstalledOrExit()
        checkFileExistsOrExit(configuration.inputFilename)
        checkOverwriteOrExit(configuration.outputFilename)
    }
    
    public static func compressedDataFrom(_ data: Data) -> Data? {
        guard !data.isEmpty else { return nil } // Check if the data is empty
        
        var source = [UInt8](data)
        var destination = [UInt8](repeating: 0,
                                  count: source.count * 2)
        
        var stream = z_stream()
        stream.next_in = UnsafeMutablePointer(mutating: &source)
        stream.avail_in = UInt32(data.count)
        stream.next_out = UnsafeMutablePointer(mutating: &destination)
        stream.avail_out = UInt32(destination.count)
        
        let initResult = deflateInit2_(&stream, Z_DEFAULT_COMPRESSION,
                                       Z_DEFLATED, -15, 8,
                                       Z_DEFAULT_STRATEGY, ZLIB_VERSION,
                                       Int32(MemoryLayout<z_stream>.size)
        )
        
        guard initResult == Z_OK else { return nil }
        
        defer { deflateEnd(&stream) }
        
        let deflateStatus = deflate(&stream, Z_FINISH)
        guard deflateStatus == Z_STREAM_END else { return nil }
        
        return Data(destination[..<Int(stream.total_out)])
    }
    
    public static func cleanupTemp(files filepaths: [String]) {
        let manager = FileManager.default
        for filepath in filepaths {
            try? manager.removeItem(atPath: filepath)
        }
    }
    
    public static func saveOutputFileAtPath(_ outputPath: String,
                                            data: Data) {
        do {
            try data.write(to: URL(fileURLWithPath: outputPath))
            Log.log("  - Saved \(data.count / 1024) KB file as \(outputPath)", .info)
        } catch {
            Log.log("Error while writing output file: \(error)", .error)
        }
    }
    
    public static func headerEncodedData(framesCount: Int,
                                         configuration: Configuration) -> Data {
        var header = Data([0x2e, 0x4d, 0x56, 0x42])
        var currentValue: UInt16 = 0
        let values = [
            framesCount,
            configuration.chunkDimension,
            configuration.frameWidth,
            configuration.frameHeight,
            configuration.targetFPS,
            configuration.skipFrames
        ]
        for value in values {
            currentValue = UInt16(value).littleEndian
            header.append(Data(bytes: &currentValue,
                               count: MemoryLayout<UInt16>.size))
        }
        return header
    }
}

// MARK: - Private methods
extension Utils {
    
    private static func ffmpegInstalledOrExit() {
        let whichFFmpeg = execute("which ffmpeg")
        guard !(whichFFmpeg.1.isEmpty || whichFFmpeg.1.contains("not found")) else {
            Log.log("ffmpeg is not installed!", .error)
            exit(1)
        }
    }
    
    private static func checkFileExistsOrExit(_ filename: String) {
        guard FileManager.default.fileExists(atPath: filename) else {
            Log.log("\(filename) doesn't exist", .error)
            exit(1)
        }
    }
    
    private static func checkOverwriteOrExit(_ filename: String) {
        if FileManager.default.fileExists(atPath: filename) {
            Log.log("[!] \(filename) already exists. Overwrite? y/(N): ", .info, terminator: "")
            if let input = readLine()?.lowercased() {
                if !["Y", "y", "Yes", "yes"].contains(input) {
                    Log.log("[i] See you!")
                    exit(0)
                }
            }
        }
    }
}

// MARK: - Extensions
extension CGSize {
    var ratio: CGFloat {
        width / height
    }
}
