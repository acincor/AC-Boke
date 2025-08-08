//
//  UIImage+Extension.swift
//  Acblog
//
//  Created by acincor on 2025/8/5.
//

import UIKit
import ImageIO
import MobileCoreServices
import UniformTypeIdentifiers
// MARK: - Image format
extension UIImage {
    func gifData(duration: TimeInterval, repeat count: Int) -> Data? {
        guard let images = self.images else {
            return nil
        }
     
        let frameCount = images.count
        let gifDuration = duration <= 0.0 ? self.duration / Double(frameCount) : duration / Double(frameCount)
     
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: gifDuration]]
        let imageProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: count]]
     
        let data = NSMutableData()
     
        guard let destination = CGImageDestinationCreateWithData(data, UTType.gif.identifier as CFString, frameCount, nil) else {
            return nil
        }
        CGImageDestinationSetProperties(destination, imageProperties as CFDictionary)
     
        for image in images {
            CGImageDestinationAddImage(destination, image.cgImage!, frameProperties as CFDictionary)
        }
     
        return CGImageDestinationFinalize(destination) ? Data(data) : nil
    }
    func gifData() -> Data? {
        return self.gifData(duration: 0.0, repeat: 0)
    }
    func data() -> Data? {
        if let data = self.gifData() {
            return data
        }
        if let data = self.pngData() {
            return data
        }
        if let data = self.jpegData(compressionQuality: 1.0) {
            return data
        }
        return nil
    }
}
