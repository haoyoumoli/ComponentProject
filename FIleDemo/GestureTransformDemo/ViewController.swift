//
//  ViewController.swift
//  GestureTransformDemo
//
//  Created by apple on 2022/5/19.
//

import UIKit

    
fileprivate
struct LayoutValues {
    static let redViewSize = CGSize(width: 280, height: 280)
    static let targetRegionSize = CGSize(width: 300, height: 300)
}


class ViewController: UIViewController {
    //视图
    let redView = UIButton()
    let targetRegion = UIButton()
    //用于更新RedView位置
    
    private
    var redViewCenterX:NSLayoutConstraint! = nil
    private
    var redViewCenterY:NSLayoutConstraint! = nil
    
    //记录长按手势的触发时的起始位置
    lazy private(set)
    var startLongProgressLocation:CGPoint = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.bringSubviewToFront(redView)
 
    }

}

//MARK: - Events
private
extension ViewController {
    @objc
    func redViewTouched(_ sender:UIButton) {
        debugPrint("redViewTouched")
    }
    
    @objc
    func handleLongProgressGesture(_ sender:UILongPressGestureRecognizer) {
        
        switch sender.state {
            
        case .possible:
            break
            
        case .began:
            startLongProgressLocation = sender.location(in: view)
            
        case .changed:
            //手势在处理
            let nowLoction = sender.location(in: view)
            let deltaX = nowLoction.x - startLongProgressLocation.x
            let deltaY = nowLoction.y - startLongProgressLocation.y
            //修改transform实现移动效果
            self.redView.transform = CGAffineTransform(translationX: deltaX, y: deltaY)
            
            //检测RedView是否和黑框有了交集
            if redView.frame.intersects(targetRegion.frame) {
                setTargetRegion(isHighLighted: true)
            } else {
                setTargetRegion(isHighLighted: false)
            }
            
        case .ended,.failed,.cancelled:
            
            //获取最新的redviewcenter
            var redViewCenter:CGPoint
            
            //检测RedView是否和黑框有了交集
            if redView.frame.intersects(targetRegion.frame) {
                //直接设置红色view和黑框的中心重合
                redViewCenter = targetRegion.center
            } else {
                redViewCenter  = CGPoint(x: redView.frame.minX + redView.bounds.width * 0.5, y: redView.frame.minY + 0.5 * redView.bounds.height)
            }
            
            //更新redview约束
            redViewCenterY.constant = redViewCenter.y
            redViewCenterX.constant = redViewCenter.x
            //还原transform
            self.redView.transform = CGAffineTransform.identity
            
        @unknown default:
            break
        }
    }
}

//MARK: - UI
private
extension ViewController {
    func setupUI() {
        redView.setTitle("将我拖拽到黑框处", for: .normal)
        redView.backgroundColor = .red
        redView.translatesAutoresizingMaskIntoConstraints  = false
        redView.addTarget(self, action: #selector(redViewTouched(_:)), for: .touchUpInside)
        let longProgressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongProgressGesture(_:)))
        redView.addGestureRecognizer(longProgressGesture)
        redViewCenterX = redView.centerXAnchor.constraint(equalTo: view.leftAnchor,constant: view.bounds.width  * 0.5)
        redViewCenterY = redView.centerYAnchor.constraint(equalTo: view.topAnchor,constant: 60 + LayoutValues.redViewSize.width * 0.5)
        view.addSubview(redView)
    
        setTargetRegion(isHighLighted: false)
        targetRegion.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(targetRegion)
        NSLayoutConstraint.activate([
            //redview
            redView.widthAnchor.constraint(equalToConstant: LayoutValues.redViewSize.width),
            redView.heightAnchor.constraint(equalToConstant: LayoutValues.redViewSize.height),
            redViewCenterX,redViewCenterY,
            //target region
            targetRegion.widthAnchor.constraint(equalToConstant: LayoutValues.targetRegionSize.width),
            targetRegion.heightAnchor.constraint(equalToConstant: LayoutValues.targetRegionSize.height),
            targetRegion.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            targetRegion.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -30)
        ])
        
    }
    
    ///修改TargetRegion边框显示
    func setTargetRegion(isHighLighted:Bool) {
        if isHighLighted {
            targetRegion.layer.borderWidth = 10.0
            targetRegion.layer.borderColor = UIColor.green.cgColor
        } else {
            targetRegion.layer.borderWidth = 2.0
            targetRegion.layer.borderColor = UIColor.black.cgColor
        }
    }
}
