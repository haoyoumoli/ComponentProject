//
//  PersonInfoDemo.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/9.
//

import Foundation
import UIKit


extension String {
    func typeMap<T>(_ transform:(String) -> T) -> T {
        return transform(self)
    }
}


//MARK: -

class PersonInfoLayout: LayoutItem<Void> {
    
    private(set) var iconL: ImageLayout
    
    private(set) var rightContainer = VerticalLayoutContainer(data: [])
    
    private(set) var nameL:AttributeStringLayout
    private(set) var detailL:AttributeStringLayout
    
    init(name:String?,icon:UIImage?,detail:String?) {
        
        
        iconL = ImageLayout.init(data: icon)
        
        
        nameL = AttributeStringLayout.init(data: name?.typeMap({
            return NSAttributedString.init(string: $0, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0),.foregroundColor:UIColor.blue])
            
        }))
        
        detailL = AttributeStringLayout.init(data: detail?.typeMap({
            return NSAttributedString.init(string: $0, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0),.foregroundColor:UIColor.green])
            
        }))
        
        rightContainer.setData([nameL,detailL])
        
        
        
        super.init(data: nil)
        
    }
    
    
    override func layoutForWidth(_ width: CGFloat) -> Self {
        
        iconL.layoutForWidth(50.0)
            .setOffset(dx: 5.0, dy: 5.0)
        
        rightContainer.spacing = 10.0
        
        rightContainer.layoutForWidth(width - iconL.frame.maxX - 10.0)
            .setOffset(dx: iconL.getFrame().maxX + 5.0, dy: iconL.frame.minY)
        
        frame = .init(x: 0, y: 0, width: width, height: max(iconL.getFrame().maxY, rightContainer.getFrame().maxY))
        
        return self
    }
}


//MARK: -
class PersonInfoView: UIView {
    
    let name = UILabel()
    let icon = UIImageView()
    let detail = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [name,icon,detail].forEach { v in
            self.addSubview(v)
        }
        icon.backgroundColor = .gray
        name.numberOfLines = 0
        detail.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func displayLayout(_ layout:PersonInfoLayout) {
        
        //        icon.image = layout.iconL.getData()
        //        icon.frame = layout.iconL.frame
        //
        //        name.attributedText = layout.nameL.getData()
        //        name.frame = layout.nameL.frame
        //
        //        detail.attributedText = layout.detailL.getData()
        //        detail.frame = layout.detailL.frame
        
        icon.displayLayout(layout.iconL)
        name.displayLayout(layout.nameL)
        detail.displayLayout(layout.detailL)
    }
}
