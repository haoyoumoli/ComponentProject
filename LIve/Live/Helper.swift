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

extension CVImageBuffer {
    func toImage() -> UIImage? {
        let flags:CVPixelBufferLockFlags = []
        guard CVPixelBufferLockBaseAddress(self, flags) != kCVReturnSuccess else {
            return nil
        }
        defer {
            CVPixelBufferUnlockBaseAddress(self, flags)
        }
        let baseAddress = CVPixelBufferGetBaseAddress(self)
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        //let bufferSize = CVPixelBufferGetDataSize(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard
            let context = CGContext.init(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue),
            let cgImg = context.makeImage()
        else {
            return nil
        }

        
        return UIImage(cgImage: cgImg)

    }
}
