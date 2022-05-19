//
//  ReuseableViewPresenter.swift
//  ComplexListDemo
//
//  Created by apple on 2022/5/17.
//

import Foundation
import UIKit


protocol ViewPresenter2 {
    associatedtype View
    func configData(for view:View)
}


protocol ReuseableView2{
    static var reuseType:UIView.Type { get }
}

extension ReuseableView2 {
    static var reuseId:String {
        return String(reflecting:reuseType)
    }
}

//MARK: - Cell
protocol CollectionCellReusablePresenter: ViewPresenter2,ReuseableView2,UICollectionViewDelegateFlowLayout where View:UICollectionViewCell {}

extension CollectionCellReusablePresenter {
    
    static var reuseType:UIView.Type { return View.self }
    
    static func registerCell(for collectionView:UICollectionView) {
        collectionView.register(reuseType, forCellWithReuseIdentifier: reuseId)
    }
}

//MARK: - Header
protocol CollectionHeaderReuseablePresenter:ViewPresenter2,ReuseableView2,UICollectionViewDelegateFlowLayout where View:UICollectionReusableView {}

extension CollectionHeaderReuseablePresenter {
    static var reuseType:UIView.Type { return View.self }
    
    static func registerHeader(for collectionView:UICollectionView) {
        collectionView.register(reuseType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseId)
    }
}

//MARK: - Footer
protocol CollectionFooterReuseablePresenter:ViewPresenter2,ReuseableView2,UICollectionViewDelegateFlowLayout where View:UICollectionReusableView {}

extension CollectionFooterReuseablePresenter {
    static var reuseType:UIView.Type { return View.self }
    
    static func registerHeader(for collectionView:UICollectionView) {
        collectionView.register(reuseType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: reuseId)
    }
}


//MARK: -
class Cell3:UICollectionViewCell {}

class Cell3Presenter:NSObject,CollectionCellReusablePresenter {
 
     func configData(for itemView: Cell3) {
        
    }
}

class Cell4:UICollectionViewCell {}


class Cell4Presenter:NSObject,CollectionCellReusablePresenter {
 
     func configData(for itemView: Cell4) {
        
    }
}

//MARK: -  Section
class CollectionViewSectionPresenter2<HeaderPresenter,CellPresenter,FooterPresenter>:NSObject
where HeaderPresenter:CollectionViewHeaderPresenter,FooterPresenter:CollectionViewFooterPresenter,
      CellPresenter:CollectionViewCellPresenter
{
    var minimumLineSpacing:CGFloat = 0.0
    var minimumInteritemSpacing:CGFloat = 0.0
    var sectionInsets:UIEdgeInsets = .zero
    
    var header:HeaderPresenter? = nil
    var footer:FooterPresenter? = nil
    var items:[CellPresenter] = []
    
    typealias DidSelectItemHanlder = (_ sectionPresenter:CollectionViewSectionPresenter2,_ collectionView:UICollectionView,_ indexPath:IndexPath) -> Void
    var didSelectItemHandler: DidSelectItemHanlder? = nil
}




//MARK: - 带泛型的协议如何统一类型管理?
