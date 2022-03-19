//
//  iOSScreens.swift
//  EmitterDemo
//
//  Created by apple on 2021/5/28.
//

import Foundation
import UIKit

struct ScreenInfo {
    let hpx:Int
    let vpx:Int
    let scale: Int
    
    var pxSize: CGSize {
        return CGSize(width: hpx , height: vpx )
    }
    
    var ptSize: CGSize {
        return CGSize(width: hpx / scale, height: vpx / scale)
    }
    
    var ratio: Decimal {
        let h = NSDecimalNumber.init(value: hpx)
        let v = NSDecimalNumber.init(value: vpx)
        let behaviors = NSDecimalNumberHandler.init(roundingMode: .up, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        let result = h.dividing(by: v, withBehavior: behaviors)
        
        return result.decimalValue
    }
}

//MARK: -
struct IphoneScreen: RawRepresentable {
    let rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    var name:String {
        return rawValue
    }
    
    var screenInfo: ScreenInfo? {
        return IphoneScreens().screenInfos[rawValue]
    }
}


//MARK: - iphone现有屏幕信息
class IphoneScreens  {

    lazy var screenInfos:[String:ScreenInfo] = [
        "iPhone 12 Pro Max": ScreenInfo(hpx: 1284, vpx: 2778, scale: 3),
        "iPhone 12 Pro":     ScreenInfo(hpx: 1170, vpx: 2532, scale: 3),
        "iPhone 12":         ScreenInfo(hpx: 1170, vpx: 2532, scale: 3),
        "iPhone 12 mini":    ScreenInfo(hpx: 1125, vpx: 2436, scale: 3),
        "iPhone 11 Pro Max": ScreenInfo(hpx: 1242, vpx: 2688, scale: 3),
        "iPhone 11 Pro":     ScreenInfo(hpx: 1125, vpx: 2436, scale: 3),
        "iPhone 11":         ScreenInfo(hpx: 828, vpx: 1792, scale: 2),
        "iPhone Xs Max":     ScreenInfo(hpx: 1242, vpx: 2688, scale: 3),
        "iPhone Xs":         ScreenInfo(hpx: 1125, vpx: 2436, scale: 3),
        "iPhone Xr":         ScreenInfo(hpx: 828, vpx: 1792, scale: 2),
        "iPhone X":          ScreenInfo(hpx: 1125, vpx: 2436, scale: 3),
        "iPhone 8 Plus":     ScreenInfo(hpx: 1080, vpx: 1920, scale: 3),
        "iPhone 8":          ScreenInfo(hpx: 750, vpx: 1334, scale: 2),
        "iPhone 7 Plus":     ScreenInfo(hpx: 1080, vpx: 1920, scale: 3),
        "iPhone 7":          ScreenInfo(hpx: 750, vpx: 1334, scale: 2),
        "iPhone 6s Plus":    ScreenInfo(hpx: 1080, vpx: 1920, scale: 3),
        "iPhone 6s":         ScreenInfo(hpx: 750, vpx: 1334, scale: 2),
        "iPhone 6 Plus":     ScreenInfo(hpx: 1080, vpx: 1920, scale: 3),
        "iPhone 6":          ScreenInfo(hpx: 750, vpx: 1334, scale: 2),
        "4.7 iPhone SE":     ScreenInfo(hpx: 750, vpx: 1334, scale: 2),
        "4 iPhone SE":       ScreenInfo(hpx: 640, vpx: 1136, scale: 2),
    ]
    
    
    /// 计算这些屏幕中有哪些宽高比(去重过的)
    var ratioSet:Set<Decimal> {
        let ratios = self.screenInfos.map({ ($0.key,$0.value.ratio)})
        var ratiosSet = Set<Decimal>()
        ratios.forEach({ ratiosSet.insert($0.1) } )
        return ratiosSet
    }
    
    func writeJson(to path:URL) throws {
        let dic = self.toDic()
        let jsonData =  try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
        try jsonData.write(to: URL(fileURLWithPath: "/Users/apple/Desktop/iphone-screen.json"))
    }
}

//MARK: - Dictionaryable

protocol Dictionaryable {
    func toDic() -> [String:Any]
}

extension CGSize:Dictionaryable {
    func toDic() -> [String:Any] {
        return [
            "width":width,
            "height":height
        ]
    }
}

extension ScreenInfo:Dictionaryable {
    func toDic() -> [String : Any] {
        return [
            "pointSize": ptSize.toDic(),
            "pixelSize":CGSize(width: hpx, height: vpx).toDic(),
            "scale":scale
        ]
    }
}

extension IphoneScreens:Dictionaryable {
    func toDic() -> [String : Any] {
        var result:[String:Any] = [:]
        screenInfos.forEach({
            result[$0.key] = $0.value.toDic()
        })
        return result
    }
}


