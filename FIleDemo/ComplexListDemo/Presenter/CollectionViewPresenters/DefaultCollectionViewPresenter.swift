//
//  CollectionViewPresenter.swift
//  ComplexListDemo
//
//  Created by apple on 2022/5/13.
//

import UIKit


/// 提供一些统一的默认实现,分发给对应的CollectionViewSectionPresenter
class DefaultCollectionViewPresenter:NSObject {
    var sections:[CollectionViewSectionPresenter] = []
}


//MARK: - UICollectionViewDataSource
extension DefaultCollectionViewPresenter:UICollectionViewDataSource  {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type(of: item).reuseId, for: indexPath)
        item.configData(for:cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let item = sections[indexPath.section]
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type(of: item.header!).reuseId, for: indexPath)
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type(of: item.footer!).reuseId, for: indexPath)
        default:
            return UICollectionReusableView()
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

///这些方法默认委托给CollectionViewSectionPresenter
extension DefaultCollectionViewPresenter:UICollectionViewDelegateFlowLayout {
    
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let sectionP = sections[section]
        return sectionP.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let sectionP = sections[section]
        return sectionP.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section)
    }

    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let sectionP = sections[section]
        return sectionP.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section)
    }
    
    
    ///size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let section = sections[indexPath.section]
      return section.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
  }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let sectionP = sections[section]
        return sectionP.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionP = sections[section]
        return sectionP.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
    }
}
