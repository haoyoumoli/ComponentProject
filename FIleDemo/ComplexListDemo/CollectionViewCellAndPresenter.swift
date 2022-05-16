//
//  SectionModel.swift
//  Live
//
//  Created by apple on 2022/5/13.
//

import Foundation
import UIKit


//MARK: - Cell
class TwoLabelCell:UICollectionViewCell {
    
    let lbl0 = UILabel()
    let lbl1 = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        lbl0.numberOfLines = 0
        lbl1.numberOfLines = 0
        lbl0.translatesAutoresizingMaskIntoConstraints = false
        lbl1.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lbl0)
        contentView.addSubview(lbl1)
        
        NSLayoutConstraint.activate([
            lbl0.topAnchor.constraint(equalTo: contentView.topAnchor),
            lbl0.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            lbl0.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            lbl1.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lbl1.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            lbl1.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])
    }
    
    func setData(txt0:NSAttributedString?,txt1:NSAttributedString?) {
        lbl0.attributedText = txt0
        lbl1.attributedText = txt1
    }
}

class TwoLabelCellPresenter:NSObject,CollectionViewCellPresenter {
    
    var txt0:String? = nil
    var txt1:String? = nil
    
    lazy private var txt0Attribute :[NSAttributedString.Key:Any] = [
        .font:UIFont.systemFont(ofSize: 16.0),
        .foregroundColor:UIColor.blue
    ]
    
    lazy private var txt1Attribute :[NSAttributedString.Key:Any] = [
        .font:UIFont.systemFont(ofSize: 14.0),
        .foregroundColor:UIColor.red
    ]
    
    
    private(set) var cellHeight:CGFloat? = nil
    
    func configData(for itemView: UIView) {
        guard let myCell = itemView as? TwoLabelCell else {
            return
        }
        let attriTxt0 = NSAttributedString.init(string: txt0 ?? "",attributes: txt0Attribute)
        let attriTxt1 = NSAttributedString.init(string: txt1 ?? "",attributes: txt1Attribute)
        myCell.setData(txt0: attriTxt0, txt1: attriTxt1)
    }
    
    static var reuseType: UIView.Type {
        return TwoLabelCell.self
    }
    
    private func fillCellHeightIfNeeded(for width:CGFloat) {
        if cellHeight == nil {
            let attriTxt0 = NSAttributedString.init(string: txt0 ?? "",attributes: txt0Attribute)
            let attriTxt1 = NSAttributedString.init(string: txt1 ?? "",attributes: txt1Attribute)
           let txt0Size = attriTxt0.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).size
            let txt1Size = attriTxt1.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).size
            cellHeight = txt0Size.height + txt1Size.height
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        fillCellHeightIfNeeded(for: collectionView.bounds.width)
        return CGSize(width: collectionView.bounds.width, height:cellHeight!)
    }
    

}

class GridCell:UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.alpha = 0.5
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.alpha = 1.0
        super.touchesEnded(touches, with: event)
    }
}

class GridCellPresenter:NSObject,CollectionViewCellPresenter {
    
    static var reuseType: UIView.Type {
        return GridCell.self
    }
    
    func configData(for itemView: UIView) {
        guard
            let cell = itemView as? GridCell else {
            return
        }
        cell.contentView.backgroundColor = UIColor.random
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 3, height: 80.0)
    }
    
}

//MARK: - Header
class RedHeader: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = .red
    }
}


class RedHeaderPresenter:NSObject,CollectionViewHeaderPresenter {
    static var reuseType: UIView.Type {
        return RedHeader.self
    }
    
    func configData(for itemView: UIView) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 30.0)
    }
}


//MARK: - Footer

class BlueFooter: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = .blue
    }
}


class BlueFooterPresenter:NSObject,CollectionViewFooterPresenter {
    static var reuseType: UIView.Type {
        return BlueFooter.self
    }
    
    func configData(for itemView: UIView) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width:0, height: 50)
    }
}


extension UIColor {
    class var random:UIColor {
        return UIColor(red: CGFloat(arc4random() % 255) / 255.0, green: CGFloat(arc4random() % 255) / 255.0, blue: CGFloat(arc4random() % 255) / 255.0, alpha: 1.0)
    }
}
