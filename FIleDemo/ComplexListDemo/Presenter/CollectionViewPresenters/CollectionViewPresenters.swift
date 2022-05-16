//
//  CollectionSectionPresenter.swift
//  ComplexListDemo
//
//  Created by apple on 2022/5/13.
//

import UIKit

//MARK: - Cell
protocol CollectionViewCellPresenter:
    ViewPresenter,ReuseableView,
    UICollectionViewDelegateFlowLayout{}


//MARK: - Header
protocol CollectionViewHeaderPresenter:
    ViewPresenter,ReuseableView,
    UICollectionViewDelegateFlowLayout{}

//MARK: - Footer
protocol CollectionViewFooterPresenter:
    ViewPresenter,ReuseableView,
    UICollectionViewDelegateFlowLayout {}


//MARK: -  Section
class CollectionViewSectionPresenter:NSObject {
    var minimumLineSpacing:CGFloat = 0.0
    var minimumInteritemSpacing:CGFloat = 0.0
    var sectionInsets:UIEdgeInsets = .zero
    
    var header:CollectionViewHeaderPresenter? = nil
    var footer:CollectionViewFooterPresenter? = nil
    var items:[CollectionViewCellPresenter] = []
}

extension CollectionViewSectionPresenter:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat  {
        return minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let item = items[indexPath.row]
      let size = item.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
      return size ?? .zero
  }
        
    //默认实现,委托给CollectionViewFooterPresenter
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let footer = self.footer
        let size = footer?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
        return size ?? .zero
    }
    
    //默认实现,委托给CollectionViewHeaderPresenter
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let header = self.header
        let size = header?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
        return size ?? .zero
    }
    
}




