//
//  Encoder.swift
//  video2mvb
//
//  Created by Onee Chan on 08.09.2023.
//

import Foundation
import CoreImage
import AVFoundation

public final class Encoder {
    
    private let configuration: Configuration
    private var sharedContext = CIContext()
    
    private var tempVideoPath: String?
    private var videoTrack: AVAssetTrack?
    private var reader: AVAssetReader?
    private var trackOutput: AVAssetReaderTrackOutput?
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
}

// MARK: - Public methods
extension Encoder {
    
    public func loadVideo() {
        guard let preparedPath = prepareVideoAt(configuration.inputFilename) else {
            Log.log("Error while encoding input video with FFmpeg", .error)
            exit(1)
        }
        self.tempVideoPath = preparedPath
    }
    
    public func loadVideoTrack() {
        guard let videoPath = tempVideoPath else {
            Log.log("You have to load a video first", .error)
            return
        }
        let asset = AVAsset(url: .init(fileURLWithPath: videoPath))
        guard let assetReader = try? AVAssetReader(asset: asset),
              let videoTrack = asset.tracks(withMediaType: .video).first else {
            Log.log("Error while loading a video track", .error)
            cleanupAndExit(1)
        }
        self.reader = assetReader
        self.videoTrack = videoTrack
    }
    
    public func readVideoTrack() {
        guard let reader,
              let videoTrack else {
            Log.log("You have to load a video track first", .error)
            return
        }
        
        let outputSettings: [String: Any] = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
        let trackOutput = AVAssetReaderTrackOutput(track: videoTrack,
                                                   outputSettings: outputSettings)
        let failureAction: () -> Never = {
            Log.log("Error while reading the video track", .error)
            self.cleanupAndExit(1)
        }
        guard reader.canAdd(trackOutput) else { failureAction() }
        reader.add(trackOutput)
        reader.startReading()
        guard reader.status == .reading else { failureAction() }
        self.trackOutput = trackOutput
    }
    
    public func startEncoding() {
        guard let trackOutput else {
            Log.log("You have to read a track first", .error)
            return
        }
        
        let factory = FrameFactory(configuration: configuration,
                                   ciContext: sharedContext)
        var currentIteration = 0
        var framesCount = 0
        var currentFrame = Frame(chunksX: configuration.chunksX,
                                 chunksY: configuration.chunksY,
                                 chunkSize: configuration.chunkDimension)
        
        var framesData = Data()
        Log.log("[i] Starting encoding \(configuration.outputFilename)..", .info)
        
        let dispatchQueue = DispatchQueue(label: "video2mvb.encodingQueue")
        let semaphore = DispatchSemaphore(value: 1)
        
        while let sampleBuffer = trackOutput.copyNextSampleBuffer() {
            semaphore.wait()
            dispatchQueue.async {
                if let frame = factory.makeFrame(from: sampleBuffer),
                   currentIteration % (self.configuration.skipFrames + 1) == 0 {
                    let frame = Frame.buildFrom(frame: frame,
                                                configuration: self.configuration)
                    let delta = currentFrame.diff(frame)
                    framesData.append(delta.asData)
                    framesCount += 1
                    currentFrame = frame
                }
                CMSampleBufferInvalidate(sampleBuffer)
                currentIteration += 1
                semaphore.signal()
            }
        }
        
        var encodedData = Utils.headerEncodedData(framesCount: framesCount,
                                                  configuration: configuration)
        encodedData.append(framesData)
        
        let framesCountString = "\(currentIteration / (configuration.skipFrames + 1))"
        Log.log("[i] Successfully encoded \(framesCountString) frames!", .info)
        Utils.cleanupTemp(files: [tempVideoPath].compactMap { $0 })
        Utils.saveOutputFileAtPath(configuration.outputFilename,
                                   data: encodedData)
    }
}

// MARK: - Private methods
extension Encoder {
    
    private func prepareVideoAt(_ path: String) -> String? {
        guard let tmpDir = URL(string: NSTemporaryDirectory()) else {
            return nil
        }
        let outputUrl = tmpDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        try? FileManager.default.removeItem(at: outputUrl)
        
        let ratioString = "\(configuration.frameWidth)/\(configuration.frameHeight)"
        let filters = [
            "scale='if(lt(a,\(ratioString)),\(configuration.frameWidth),-1)':'if(lt(a,\(ratioString)),-1,\(configuration.frameHeight))'",
            "crop=\(configuration.frameWidth):\(configuration.frameHeight)"
        ].joined(separator: ",")
        
        let args = [
            "-nostdin",
            "-i", path,
            "-vf", "\"\(filters)\"",
            "-r", "\(configuration.targetFPS)",
            "-c:v", "libx264",
            outputUrl.absoluteString
        ]
        let argsStr = args.joined(separator: " ")
        let cmd = "ffmpeg \(argsStr)"
        
        Log.log("[i] Re-encoding the input video to target frame size & FPS..", .info)
        let result = Utils.execute(cmd)
        return result.0 ? outputUrl.absoluteString : nil
    }
    
    private func cleanupAndExit(_ code: Int32) -> Never {
        guard let tempVideoPath else { exit(code) }
        Utils.cleanupTemp(files: [tempVideoPath])
        exit(code)
    }
}
