//
//  TwoItemGridSection.swift
//  ComplexListDemo
//
//  Created by apple on 2022/5/16.
//

import UIKit


class TwoItemGridSection: CollectionViewSectionPresenter {
    

    //重写,控制元素大小
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - minimumInteritemSpacing - sectionInsets.left - sectionInsets.right) / 2
        return CGSize(width: width, height: 80)
    }
    
}
