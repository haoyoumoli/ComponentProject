
import Foundation
import UIKit


class PriceFormatter {
    
    private(set) var textStorage:String = ""
    private(set) var displayText:NSAttributedString = NSAttributedString.init(string: "")
    
    func formatText(_ text:String) {
        debugPrint(text)
        var text = text
        text.removeAllChatBeforeYuanMarket()
        text.removeAllComaed()
        text.removeAllYuanMark()
        text.removeAllZeroBeforeNumber()
        text.changeToDecimalIfNeeded()
        text.saveTwoCharAfterDot()

        textStorage = text
        displayText = getPriceAttributestring(for: textStorage)
        debugPrint(displayText.string)
    }
}

private extension PriceFormatter {
    private func getPriceAttributestring(for price:String) -> NSAttributedString {
        let str1 =  NSMutableAttributedString.init(string: "¥")
        ///添加逗号
        let str2 = NSMutableAttributedString.init(string: price)
        str1.append(str2)
        return str1
    }
}

private
extension String {
    
    ///移除¥前面的多个字符
    mutating func removeAllChatBeforeYuanMarket() {
        if let index = firstIndex(of: "¥") {
            self = String(suffix(from: index))
        }
    }
    
    ///移除所有数字之前的0
    mutating func removeAllZeroBeforeNumber() {
        while self.count > 0 {
            let idx = self.startIndex
            if self[idx] == "0" {
               self.remove(at: idx)
            } else {
                break
            }
        }
    }
    
    mutating func removeAllYuanMark() {
        //移除人民币"¥"
        while let index = firstIndex(of: "¥") {
            remove(at: index)
        }
    }
    
    mutating func removeAllComaed() {
        while let index = self.lazy.firstIndex(of: ",") {
            self.remove(at: index)
        }
    }
    

    mutating func changeToDecimalIfNeeded() {
         //移除所有的点,只保留最后一个点
        var lastDotIdx = lastIndex(of: ".")
        
        while let index = firstIndex(of: "."),index != lastDotIdx {
            remove(at: index)
            lastDotIdx = lastIndex(of: ".")
        }
          
    }
    
    mutating func saveTwoCharAfterDot() {
        guard let lastDotIdx = lastIndex(of: ".") else {
            return
        }
        let d = distance(from: lastDotIdx, to: endIndex)
        if d > 3 {
            ///小数点后大于2位, 只保留小数点后第一位和最后一位其余的位删除
            let afterDotFisrt = index(lastDotIdx, offsetBy: 2)
            
            let lastIndex = index(before: endIndex)
            self = "\(String(self.prefix(upTo: afterDotFisrt)))\(self.suffix(from: lastIndex))"
        }
    }
    
  
}


