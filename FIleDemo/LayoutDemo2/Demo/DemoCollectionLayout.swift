//
//  DemoCollectionLayout.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/11.
//

import Foundation
import UIKit

class DemoCollectionLayout: UICollectionViewFlowLayout {
    
    private var minYs:[UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        minYs.removeAll()
    }
    

    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result = super.layoutAttributesForElements(in: rect)

        ///每次更新,修改Section1中所有Item的坐标,不然如果每次修改一部分会有问题
        let count = self.collectionView?.numberOfItems(inSection: 1) ?? 0
        for i in 0..<count {
            let indexPath = IndexPath(item: i, section: 1)
            if let attribute = super.layoutAttributesForItem(at: indexPath) {

                if i > 1,
                   let min = minYs.first
                {
                    attribute.frame = CGRect(x:min.frame.minX, y: min.frame.maxY + self.minimumLineSpacing, width: attribute.frame.width, height: attribute.frame.height)


                    minYs.removeFirst()
                    insertToMinYs(attribute)


                } else {
                    // section1 的第0个,或者第一个

                    if i == 1 {
                        attribute.frame = CGRect(x:attribute.frame.minX, y: minYs.first!.frame.minY , width: attribute.frame.width, height: attribute.frame.height)
                    }
                    else {
                        attribute.frame = CGRect(x:attribute.frame.minX, y: attribute.frame.minY + minimumInteritemSpacing, width: attribute.frame.width, height: attribute.frame.height)
                    }


                    insertToMinYs(attribute)
                }

                if let idx = result?.firstIndex(where: { $0.indexPath == indexPath }) {
                    result?[idx] = attribute
                } else {
                    result?.append(attribute)
                }

            }

        }
        return result
    }
    
    
    private func insertToMinYs(_ attribute:UICollectionViewLayoutAttributes) {
        minYs.append(attribute)
        minYs.sort(by: { $0.frame.maxY < $1.frame.maxY })
    }
    
    override var collectionViewContentSize: CGSize {
        let superSize = super.collectionViewContentSize
        if minYs.count > 0 {
            let size = CGSize(width: collectionView?.frame.width ?? 0.0, height: minYs.last?.frame.maxY ?? 0.0 + sectionInset.bottom)
            return size
        }
        return superSize
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let result =  super.shouldInvalidateLayout(forBoundsChange: newBounds)
        return result
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        debugPrint(#function,updateItems)
        super.prepare(forCollectionViewUpdates: updateItems)
    }
}
