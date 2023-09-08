//
//  FrameFactory.swift
//  video2mvb
//
//  Created by Onee Chan on 30.08.2023.
//

import Foundation
import CoreImage
import CoreMedia

public final class FrameFactory {
    
    private let configuration: Configuration
    private let context: CIContext
    
    public init(configuration: Configuration,
                ciContext: CIContext) {
        self.configuration = configuration
        self.context = ciContext
    }
}

// MARK: - Public methods
extension FrameFactory {
    
    public func makeFrame(from sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        var frame = CIImage(cvPixelBuffer: imageBuffer)
        
        if !frame.extent.size.equalTo(configuration.frameSize) {
            frame = scaledFrame(from: frame)
            frame = croppedFrame(from: frame)
        }
        
        return context.createCGImage(frame,
                                     from: CGRect(origin: frame.extent.origin,
                                                  size: configuration.frameSize))
    }
}

// MARK: - Private methods
extension FrameFactory {
    
    private func croppedFrame(from image: CIImage) -> CIImage {
        let imageSize = image.extent.size
        let cropRect: CGRect
        
        if imageSize.ratio < configuration.frameRatio {
            let targetWidth = imageSize.width
            let targetHeight = targetWidth / configuration.frameRatio
            let yOffset = (image.extent.size.height - targetHeight) / 2.0
            cropRect = CGRect(x: 0.0,
                              y: yOffset,
                              width: targetWidth,
                              height: targetHeight)
        } else {
            let targetHeight = image.extent.size.height
            let targetWidth = targetHeight * configuration.frameRatio
            let xOffset = (image.extent.size.width - targetWidth) / 2.0
            cropRect = CGRect(x: xOffset,
                              y: 0.0,
                              width: targetWidth,
                              height: targetHeight)
        }
        return image.cropped(to: cropRect)
    }
    
    private func scaledFrame(from image: CIImage) -> CIImage {
        let imageSize = image.extent.size
        let scale: CGFloat
        
        if imageSize.ratio > configuration.frameRatio {
            scale = CGFloat(configuration.frameHeight) / imageSize.height
        } else {
            scale = CGFloat(configuration.frameWidth) / imageSize.width
        }
        
        if let scaledFilter = CIFilter(name: "CILanczosScaleTransform") {
            scaledFilter.setValue(image, forKey: kCIInputImageKey)
            scaledFilter.setValue(scale, forKey: kCIInputScaleKey)
            scaledFilter.setValue(1.0, forKey: kCIInputAspectRatioKey)
            
            if let outputImage = scaledFilter.outputImage {
                return outputImage
            }
        }
        return image
    }
}
