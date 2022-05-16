//
//  UICollectionView+RegisterPresenter.swift
//  ComplexListDemo
//
//  Created by apple on 2022/5/13.
//

import UIKit


extension UICollectionView {
    func register(cellPresenterType:CollectionViewCellPresenter.Type) {
        self.register(cellPresenterType.reuseType, forCellWithReuseIdentifier: cellPresenterType.reuseId)
    }
    
    func register(headerPresenterType:CollectionViewHeaderPresenter.Type) {
        
        self.register(headerPresenterType.reuseType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:headerPresenterType.reuseId)
    }
    
    func register(footerPresenterType:CollectionViewFooterPresenter.Type) {
        self.register(footerPresenterType.reuseType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier:footerPresenterType.reuseId)
    }
}
