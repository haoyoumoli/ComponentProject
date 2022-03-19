//
//  DemoCollectionViewVC.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/11.
//

import Foundation
import UIKit

/**
 使用Auto Layout 实现CollectionView cell的自适应大小
 
 collection view 有多个两个不同的section:
    section 0: 是cell大小固定的情况
    section 1: 是cell大小根据内容而定并且有一定的异步性,(图片在下载之后才能知道大小)
 
 实现这一逻辑的核心是是实现UICollectionViewCell 的
 func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes 方法,在这个方法中计算cell的大小
 
 section 1的cell 的难点是 image初始高度是0 ,拿到图片之后还要更新约束,并手动触发重新布局(注意这里不能是reload,否则会有一闪一闪的奇怪现象),
 才能实现先展示文字,图片下载完成再显示图片的效果
 
 */

//MARK: - UIDevice延展
public extension UIDevice {

var modelName: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8 ,
              value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }

    switch identifier {
    case "iPod1,1":  return "iPod Touch 1"
    case "iPod2,1":  return "iPod Touch 2"
    case "iPod3,1":  return "iPod Touch 3"
    case "iPod4,1":  return "iPod Touch 4"
    case "iPod5,1":  return "iPod Touch (5 Gen)"
    case "iPod7,1":   return "iPod Touch 6"

    case "iPhone3,1", "iPhone3,2", "iPhone3,3":  return "iPhone 4"
    case "iPhone4,1":  return "iPhone 4s"
    case "iPhone5,1":   return "iPhone 5"
    case  "iPhone5,2":  return "iPhone 5 (GSM+CDMA)"
    case "iPhone5,3":  return "iPhone 5c (GSM)"
    case "iPhone5,4":  return "iPhone 5c (GSM+CDMA)"
    case "iPhone6,1":  return "iPhone 5s (GSM)"
    case "iPhone6,2":  return "iPhone 5s (GSM+CDMA)"
    case "iPhone7,2":  return "iPhone 6"
    case "iPhone7,1":  return "iPhone 6 Plus"
    case "iPhone8,1":  return "iPhone 6s"
    case "iPhone8,2":  return "iPhone 6s Plus"
    case "iPhone8,4":  return "iPhone SE"
    case "iPhone9,1":   return "国行、日版、港行iPhone 7"
    case "iPhone9,2":  return "港行、国行iPhone 7 Plus"
    case "iPhone9,3":  return "美版、台版iPhone 7"
    case "iPhone9,4":  return "美版、台版iPhone 7 Plus"
    case "iPhone10,1","iPhone10,4":   return "iPhone 8"
    case "iPhone10,2","iPhone10,5":   return "iPhone 8 Plus"
    case "iPhone10,3","iPhone10,6":   return "iPhone X"

    case "iPad1,1":   return "iPad"
    case "iPad1,2":   return "iPad 3G"
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":   return "iPad 2"
    case "iPad2,5", "iPad2,6", "iPad2,7":  return "iPad Mini"
    case "iPad3,1", "iPad3,2", "iPad3,3":  return "iPad 3"
    case "iPad3,4", "iPad3,5", "iPad3,6":   return "iPad 4"
    case "iPad4,1", "iPad4,2", "iPad4,3":   return "iPad Air"
    case "iPad4,4", "iPad4,5", "iPad4,6":  return "iPad Mini 2"
    case "iPad4,7", "iPad4,8", "iPad4,9":  return "iPad Mini 3"
    case "iPad5,1", "iPad5,2":  return "iPad Mini 4"
    case "iPad5,3", "iPad5,4":   return "iPad Air 2"
    case "iPad6,3", "iPad6,4":  return "iPad Pro 9.7"
    case "iPad6,7", "iPad6,8":  return "iPad Pro 12.9"
    case "AppleTV2,1":  return "Apple TV 2"
    case "AppleTV3,1","AppleTV3,2":  return "Apple TV 3"
    case "AppleTV5,3":   return "Apple TV 4"
    case "i386", "x86_64":   return "Simulator"
    default:  return identifier
    }
}
}



class DemoCollectionVC: UIViewController {
    
    private(set) var collectionView:UICollectionView? = nil
    
    var data: [(String,String,UIImage?)] = [
        ("https://img1.ali213.net/glpic/2020/09/08/584_2020090835824689.gif","如果对手英雄的生命值非常高，那么科莱特的普通攻击就能够打出非常高的伤害。但是，如果对手英雄的生命值非常低的话，科莱特的普通攻击就明显是不够看的了。另外，对于宝箱的造成的伤害则是固定的哦。科莱特的超级技能是发动冲锋，抵达终点后再返回原来的位置，所有被她撞到的英雄都会受到伤害。",nil),
        
        ("https://img2.ali213.net/picfile/News/2020/06/04/584_9cb17528-41b3-aec5-8efa-f26cd8ab987b.jpg","柯尔特的攻击命中率太低，也十分容易躲避。柯尔特单次攻击虽然高伤害，但是其攻击的伤害是由每颗子弹累积起来的。很多时候，只能蹭到一点伤害，而没有办法把伤害打满。纯直线的单调攻击模式加上其命中难度高，使之在新版本环境下成为版本之殇。",nil),
        
        ("https://pics3.baidu.com/feed/1e30e924b899a901c13771a2bf56c57d0308f56a.jpeg?token=d0c1dc3b73077f52c7b5d27a795a97de","定位：坦克获得方式：玩家获得250奖杯时就能解锁公牛优点：公牛的血量厚，普攻伤害高。在1v1的对战中，公牛可以用三发普攻在贴身的情况下，秒杀任何一个敌人。还可以利用血量优势替队友抗伤，掩护队友进攻。公牛是为数不多拥有位移技能的英雄，他以到达距离为12格的任意范围。缺点：公牛的普通攻击是雪莉的缩小版，所以大致玩法跟雪莉类似，但也有不同于雪莉的地方，他的攻击距离特别短，且换弹速度慢，公牛只有贴身才能打中敌人，不能像雪莉一样打远程消耗。公牛可以克制一些近战英雄，比如弗兰克、达里尔、莫提斯、罗莎等。他也会被一些远程英雄克制，比如妮塔、杰西、阿渤、雪莉等。",nil),
        
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data.append(contentsOf: data)
        data.append(contentsOf: data)
        setupUI()
    

        let group = DispatchGroup.init()
        self.collectionView?.refreshControl?.beginRefreshing()
        for  i in 0..<data.count {
            group.enter()
            UIImage.loadImage(data[i].0) {[weak self] loadedImage in
                self?.data[i].2 = loadedImage
                group.leave()
                //self.collectionView?.reloadItems(at: [indexPath])
            }
        }

        group.notify(queue: .main) {
            self.collectionView?.dataSource = self
            self.collectionView?.refreshControl?.endRefreshing()
            self.collectionView?.reloadData()
        }
    
        
        self.collectionView?.dataSource = self
        self.collectionView?.reloadData()
        
       
        
    }
    
    func setupUI() {
        
        let flowLayout = DemoCollectionLayout.init()
        flowLayout.minimumLineSpacing = 20.0
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.sectionInset = .init(top: 0, left: 10.0, bottom: 0.0, right: 10.0)

        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionView?.backgroundColor = .white
        
        collectionView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        
        collectionView!.delegate = self
        
        collectionView!.register(DemoCollectionCell.self, forCellWithReuseIdentifier: "DemoCollectionCell")
        collectionView!.register(DemoCollectionNormalCell.self, forCellWithReuseIdentifier: "DemoCollectionNormalCell")
        
        NSLayoutConstraint.activate([
            collectionView!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0),
            collectionView!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0),
            collectionView!.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            collectionView!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
        ])
        
        let refreshControl = UIRefreshControl()
        collectionView?.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl(refreshControl:)), for: .valueChanged)
        
    }
    
    @objc func handleRefreshControl(refreshControl:UIRefreshControl) {
        
        ///清空已经下载的图片
        for i in 0..<data.count {
            data[i].2 = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.collectionView?.reloadData()
            refreshControl.endRefreshing()
        })
    }
}

extension DemoCollectionVC: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if section == 0 { return 0 }
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //debugPrint(#function,indexPath)
        
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DemoCollectionCell", for: indexPath) as! DemoCollectionCell
            cell.customView.lbl.text = self.data[indexPath.item].1
            let image = self.data[indexPath.item].2
            if image == nil {
                UIImage.loadImage(self.data[indexPath.item].0) { [self] loadedImage in
                    debugPrint(indexPath)
                    self.data[indexPath.item].2 = loadedImage
                    
                    
                    ///直接更新布局
//                    cell.customView.img.image = loadedImage
//                    cell.customView.setNeedsUpdateConstraints()
//                    ///触发重新布局
//                    self.collectionView?.collectionViewLayout.invalidateLayout()
                    
//                    let flowLayoutCotext = UICollectionViewFlowLayoutInvalidationContext()
//                    var items = [IndexPath]()
//                    for j in 0..<2 {
//                        for i in 0..<data.count {
//                            items.append(IndexPath(item: i, section: j))
//                        }
//                    }
//
//                    flowLayoutCotext.invalidateItems(at: items)
//                    self.collectionView?.collectionViewLayout.invalidateLayout(with: flowLayoutCotext)
                    
                    
                    //reaload 单个item
                    CATransaction.setDisableActions(true)
                    self.collectionView?.reloadItems(at: [indexPath])
                    CATransaction.commit()
                    

                }
            }
            else {
                cell.customView.img.image = image
                cell.customView.setNeedsUpdateConstraints()
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DemoCollectionNormalCell", for: indexPath) as! DemoCollectionNormalCell
            cell.contentView.backgroundColor = UIColor(red: CGFloat(Int(arc4random() % 255)) / 255.0, green: CGFloat(Int(arc4random() % 255)) / 255.0, blue: CGFloat(Int(arc4random() % 255)) / 255.0, alpha: 1.0)
            cell.lbl.text = "\(indexPath.item)"
            return cell
        }
    }
    
    
    private func invalidIndexPaths() -> [IndexPath] {
        var result = [IndexPath]()
        for i in 0..<data.count {
            result.append(IndexPath(item: i, section: 1))
        }
        return result
    }
}
