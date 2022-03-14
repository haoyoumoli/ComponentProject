//
//  UIImageView+VideoFirstImage.swift
//  VideoPlayDemo
//
//  Created by apple on 2022/3/14.
//

import UIKit
import SDWebImage
import AVFoundation

fileprivate
func getVideoFirstImage(url:URL,completion:@escaping (UIImage?) -> Void) {
    let assert = AVURLAsset.init(url: url)
    let imageGener = AVAssetImageGenerator.init(asset: assert)
    imageGener.appliesPreferredTrackTransform = true
    
    let key = SDWebImageManager.shared.cacheKey(for: url)
    
    SDImageCache.shared.queryImage(forKey: key, options: [], context: nil) { image, data, cacheType in
        if image == nil {
            var actualTime:CMTime = CMTime()
            do {
                let cgImage = try imageGener.copyCGImage(at: CMTime.init(seconds: 0.0, preferredTimescale: 600), actualTime: &actualTime)
                let videoImage = UIImage.init(cgImage: cgImage)
                SDImageCache.shared.store(videoImage, forKey: key)
                completion(videoImage)
            } catch let err {
                debugPrint(err)
                completion(nil)
            }
        } else {
#if DEBUG
            var cachetypeString = "其它"
            if cacheType == SDImageCacheType.memory {
                cachetypeString = "内存"
            } else if cacheType == SDImageCacheType.disk {
                cachetypeString = "磁盘"
            }
            
            debugPrint("缓存命中\(cachetypeString)")
#endif
            completion(image)
        }
    }
    
}

extension UIImageView {
    func displayVideoFirstImage(url:URL) {
        asyncMeasure("测试加载视频第一帧") { finishHanlder in
            getVideoFirstImage(url: url) { [weak self] image  in
                finishHanlder()
                self?.image = image
            }
        }
    }
}
