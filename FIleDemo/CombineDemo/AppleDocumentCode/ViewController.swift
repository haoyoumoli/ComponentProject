//
//  ViewController.swift
//  CombineDemo
//
//  Created by apple on 2021/6/9.
//

import UIKit
import Combine



class ViewController: UIViewController {
    
    let appleCode = CombineCode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("start")
        
        var elements = Array<Int>()
        elements.insert(1, at: 0)
        elements.insert(2, at: 0)
        debugPrint(elements)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       // appleCode.main()
        
        
        let result = FileItem.fileItemsForDirPath(NSHomeDirectory())


        debugPrint(result.compactMap({ return $0.fileName }))
        
    
    }
    
    
    /// 测试在打包之后再项目中添加文件,能否被读取到
    func testReadFileAfterArchive() {
        if
            let path = Bundle.main.path(forResource: "aaa.txt", ofType: nil),
            let string = try? String(contentsOf: URL(fileURLWithPath: path))  {
            debugPrint(string)
        }
    }
    
    func testVolume() {
        let url = NSURL.init(fileURLWithPath: NSHomeDirectory())
        
        var volumeURL:AnyObject? = nil
        var volumeName:AnyObject? = nil
        try? url.getResourceValue(&volumeURL, forKey: URLResourceKey.volumeURLKey)
        try? url.getResourceValue(&volumeName, forKey: URLResourceKey.volumeNameKey)
        
        debugPrint(volumeURL as Any,volumeName as Any)
    }
    
    
    
    
    func wwdc2019_advances_in_collection_view_layout() {
        
        do {
            let size = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0), heightDimension: .absolute(40))
            
            let item = NSCollectionLayoutItem(layoutSize: size)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            let layout = UICollectionViewCompositionalLayout(section: section)
        }
        
        do {
            //NSCollectionLayoutAnchor
            let badgeAnchor = NSCollectionLayoutAnchor(edges: [.top,.trailing],fractionalOffset: CGPoint(x: 0.3, y: -0.3))
            
            let badgeSize = NSCollectionLayoutSize(widthDimension: .absolute(30), heightDimension: .absolute(30))
            
            let badge = NSCollectionLayoutSupplementaryItem(layoutSize: badgeSize,elementKind: "badge",containerAnchor: badgeAnchor)
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize.init(widthDimension: .absolute(50), heightDimension: .absolute(50)),
                                              supplementaryItems: [badge])
        }
        
        
        do {
            //header and footer
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50)), elementKind: "header", alignment: .top)

            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50)),elementKind: "footer",alignment: .bottom)
            
            header.pinToVisibleBounds = true
            
            let sectionSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            
            let section = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.init(layoutSize:sectionSize))
            
            section.boundarySupplementaryItems = [header,footer]
        }
    }
}

