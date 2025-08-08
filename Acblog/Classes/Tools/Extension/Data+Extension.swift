//
//  Data+Extension.swift
//  Acblog
//
//  Created by acincor on 2025/8/5.
//
import UIKit
extension Data {
    enum ImageType: String {
        case unknown = "unknown"
        case jpeg = "image/jpeg"
        case jpeg2000 = "image/jp2"
        case tiff = "image/tiff"
        case bmp = "image/bmp"
        case ico = "image/vnd.microsoft.icon"
        case icns = "image/x-icon"
        case gif = "image/gif"
        case png = "image/png"
        case webp = "image/webp"
    }
    enum Extended: String {
        case unknown = ""
        case jpeg = "jpeg"
        case jpeg2000 = "jp2"
        case tiff = "tiff"
        case bmp = "bmp"
        case ico = "ico"
        case icns = "icns"
        case gif = "gif"
        case png = "png"
        case webp = "webp"
    }
    func detectImageType() -> (Data.ImageType,Data.Extended) {
        if self.count < 16 { return (.unknown,.unknown) }
        
        var value = [UInt8](repeating:0, count:1)
        
        self.copyBytes(to: &value, count: 1)
        
        switch value[0] {
        case 0x4D, 0x49:
            return (.tiff,.tiff)
        case 0x00:
            return (.ico,.ico)
        case 0x69:
            return (.icns,.icns)
        case 0x47:
            return (.gif,.gif)
        case 0x89:
            return (.png,.png)
        case 0xFF:
            return (.jpeg,.jpeg)
        case 0x42:
            return (.bmp,.bmp)
        case 0x52:
            let subData = self.subdata(in: Range(NSMakeRange(0, 12))!)
            if let infoString = String(data: subData, encoding: .ascii) {
                if infoString.hasPrefix("RIFF") && infoString.hasSuffix("WEBP") {
                    return (.webp,.webp)
                }
            }
            break
        default:
            break
        }
        
        return (.unknown,.unknown)
    }
    
    static func detectImageType(with url: URL) -> (Data.ImageType,Data.Extended) {
        if let data = try? Data(contentsOf: url) {
            return data.detectImageType()
        } else {
            return (.unknown,.unknown)
        }
    }
    
    static func detectImageType(with filePath: String) -> (Data.ImageType,Data.Extended) {
        let pathUrl = URL(fileURLWithPath: filePath)
        if let data = try? Data(contentsOf: pathUrl) {
            return data.detectImageType()
        } else {
            return (.unknown,.unknown)
        }
    }
    
    static func detectImageType(with imageName: String, bundle: Bundle = Bundle.main) -> (Data.ImageType?,Data.Extended?) {
        
        guard let path = bundle.path(forResource: imageName, ofType: "") else { return (nil,nil) }
        let pathUrl = URL(fileURLWithPath: path)
        if let data = try? Data(contentsOf: pathUrl) {
            return data.detectImageType()
        } else {
            return (nil,nil)
        }
    }
    
    
}
