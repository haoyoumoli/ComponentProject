//
//  NSAttributeString+GetSize.swift
//  DDD
//
//  Created by apple on 2022/7/22.
//

import UIKit
import CoreText

extension NSAttributedString {
    func getSize(for width:CGFloat,maxLine:Int) -> CGSize {
        
        let textContainzer = NSTextContainer.init(size: CGSize.init(width: width, height: .greatestFiniteMagnitude))
        textContainzer.maximumNumberOfLines = maxLine
        
        let textStorage = NSTextStorage()
        textStorage.setAttributedString(self)
        
        let layoutManage = NSLayoutManager()
        layoutManage.addTextContainer(textContainzer)
        textStorage.addLayoutManager(layoutManage)
        
        //layoutManage.drawGlyphs(forGlyphRange: .init(location: 0, length: textStorage.length), at: .zero)
      //  layoutManage.ensureGlyphs(forCharacterRange: .init(location: 0, length: self.length))
        layoutManage.ensureLayout(for: textContainzer)
        let rect = layoutManage.usedRect(for: textContainzer)
        return rect.size
    }
    
    func getSize2(for width:CGFloat,maxLine:Int) -> CGSize {
        var totalHeight = 0.0
        let frameSetter = CTFramesetterCreateWithAttributedString(self)
        let path = UIBezierPath.init(rect: .init(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        let textFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path.cgPath, nil)
        guard let lines = CTFrameGetLines(textFrame) as? [CTLine] else {
            return .zero
        }
        
        var origins: UnsafeMutablePointer<CGPoint>  = .allocate(capacity: lines.count)
        //origins.assign(repeating: .zero, count: lines.count)
       // defer { origins.deallocate() }

        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins)
        for i in stride(from: 0, through: lines.count, by: 1) {
            debugPrint(origins[i])
        }
        
        var ascent:CGFloat = 0.0
        var descent:CGFloat = 0.0
//        if let lastLine = lines.last {
//            CTLineGetTypographicBounds(lastLine, &ascent, &descent, nil)
//        }
      

        for l in lines {

            CTLineGetTypographicBounds(l, &ascent, &descent, nil)
            let bounds = CTLineGetBoundsWithOptions(l, .useOpticalBounds)
            //totalHeight += (ascent + descent)
            totalHeight += bounds.height
        }
        return .init(width: width, height:totalHeight)
        
    }
}
