//
//  Helper.swift
//  Live
//
//  Created by apple on 2022/3/30.
//

import Foundation
import CoreVideo
import UIKit
import CoreGraphics
import VideoToolbox

extension CVImageBuffer {
    func toImage() -> UIImage? {
        let flags:CVPixelBufferLockFlags = []
        guard CVPixelBufferLockBaseAddress(self, flags) == kCVReturnSuccess else {
            return nil
        }
        defer {
            CVPixelBufferUnlockBaseAddress(self, flags)
        }
        let baseAddress = CVPixelBufferGetBaseAddress(self)
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let bufferSize = CVPixelBufferGetDataSize(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.none.rawValue
        guard
            let context = CGContext.init(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo),
            let cgImg = context.makeImage()
        else {
            return nil
        }
        return UIImage(cgImage: cgImg)

    }
    
    func toImage2() -> UIImage? {
        let flags:CVPixelBufferLockFlags = []
        guard CVPixelBufferLockBaseAddress(self, flags) == kCVReturnSuccess else {
            return nil
        }
        defer {
            CVPixelBufferUnlockBaseAddress(self, flags)
        }
        guard let baseAddress = CVPixelBufferGetBaseAddress(self) else {
            debugPrint("CVPixelBufferGetBaseAddress failed")
            return nil
        }
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let bufferSize = CVPixelBufferGetDataSize(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let provider = CGDataProvider.init(dataInfo: nil, data: baseAddress, size: bufferSize,releaseData: { p1, p2, size in
            debugPrint("release")
       }) else {
           debugPrint("创建CGDataProvider失败")
           return nil
       }
        
        guard let cgImage = CGImage.init(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: [], provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
            debugPrint("CGImage.init failed")
            return nil
        }
        
        return UIImage.init(cgImage: cgImage)

    }
    
    func toImage3() -> UIImage? {
        let ciImage = CIImage.init(cvImageBuffer: self)
        let tempContext = CIContext.init(options: nil)
        guard let cgImage = tempContext.createCGImage(ciImage, from: .init(x: 0, y: 0, width: CVPixelBufferGetWidth(self), height: CVPixelBufferGetHeight(self))) else {
            debugPrint("createCGImage failed")
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

extension OSStatus {
    func debugPrint() {
        if self == kVTVideoDecoderAuthorizationErr {
            Swift.debugPrint("kVTVideoDecoderAuthorizationErr")
        } else if self == kVTVideoDecoderBadDataErr {
            Swift.debugPrint("kVTVideoDecoderBadDataErr")
        } else if self == kVTVideoDecoderMalfunctionErr {
            Swift.debugPrint("kVTVideoDecoderMalfunctionErr")
        } else if self == kVTVideoDecoderNotAvailableNowErr {
            Swift.debugPrint("kVTVideoDecoderNotAvailableNowErr")
        } else if self == kVTVideoDecoderUnsupportedDataFormatErr {
            Swift.debugPrint("kVTVideoDecoderUnsupportedDataFormatErr")
        } else if self == kVTVideoEncoderAuthorizationErr {
            Swift.debugPrint("kVTVideoEncoderAuthorizationErr")
        } else if self == kVTVideoEncoderMalfunctionErr {
            Swift.debugPrint("kVTVideoEncoderMalfunctionErr")
        } else if self == kVTVideoEncoderNotAvailableNowErr {
            Swift.debugPrint("kVTVideoEncoderNotAvailableNowErr")
        } else if self == noErr {
            Swift.debugPrint("noErr")
        } else {
            Swift.debugPrint("other")
        }
    }
}
