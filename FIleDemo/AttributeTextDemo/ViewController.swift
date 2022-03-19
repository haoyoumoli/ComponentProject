//
//  ViewController.swift
//  AttributeTextDemo
//
//  Created by apple on 2021/10/14.
//

import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController {
    
    let textView = UITextView()
    var controlContainer:BuilderControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        //setupUI()
        testUIControlContainer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //demoForDisplayPictureAndText()
        //demoForTextDownPicture()
        //demoForTextDownPicture2()
        controlContainer.frame = view.bounds
    }
}

//MARK: - Demos
extension ViewController {
    func demoForDisplayPictureAndText() {
        //构造图片富文本
        let font = UIFont.systemFont(ofSize: 40.0, weight: .bold)
        let girlImage = UIImage(named: "girl")!
        let pictureAttachment = NSTextAttachment.init(image: girlImage)
        
        ///设置x不起作用,
        ///图片与文字默认底部对齐
        ///设置y为font.descender 可以使图片与文字中心对齐
        pictureAttachment.bounds = .init(x:0, y: font.descender, width: font.lineHeight, height: font.lineHeight)

        let pictureAttriStr = NSMutableAttributedString.init(attachment: pictureAttachment)

    
        //构造显示富文本
        let displayAttri = NSMutableAttributedString.init(string: "Pretty Girl", attributes: [
            .font: font,
            .foregroundColor:UIColor.black
        ])
        displayAttri.append(pictureAttriStr)
        textView.attributedText  = displayAttri
    }
    
    ///在文字的正下方显示图片,并且保证图片的宽高比
    func demoForTextDownPicture() {
        //构造图片富文本
        let font = UIFont.systemFont(ofSize: 40.0, weight: .bold)
        let attributes:[NSAttributedString.Key:Any] = [
            .font: font,
            .foregroundColor:UIColor.black
        ]
        let girlImage = UIImage(named: "girl")!
        let pictureAttachment = NSTextAttachment.init(image: girlImage)
        
        /// textview 绘制文字并不是从0开始
        let width = textView.textContainer.size.width - 10.0
        pictureAttachment.bounds = .init(x:0, y: 0, width:  width, height: width * girlImage.size.height / girlImage.size.width)

        let pictureAttriStr = NSMutableAttributedString.init(attachment: pictureAttachment)


        //构造显示富文本
        let displayAttri = NSMutableAttributedString.init(string: "Pretty Girl\nPretty Girl\n", attributes: attributes )
    
        // spacing 用于控制间距添加一个空图片用于控制间距
        // 但是这样删除文本的时候会有问题
        let spacingAttach = NSTextAttachment.init(image: UIImage())
        spacingAttach.bounds = .init(x: 0, y: 0, width: width, height: 40.0)
        let spacingAttri = NSMutableAttributedString.init(attachment: spacingAttach)
        spacingAttri.append(NSAttributedString.init(string: "\n", attributes: nil))
        displayAttri.append(spacingAttri)
        
        
        
        displayAttri.append(pictureAttriStr)
        textView.attributedText  = displayAttri
    }
    
    ///在文字的正下方显示图片,并且保证图片的宽高比
    ///使用图片合成的方式控制间距
    func demoForTextDownPicture2() {
        //构造图片富文本
        let font = UIFont.systemFont(ofSize: 40.0, weight: .bold)
        let attributes:[NSAttributedString.Key:Any] = [
            .font: font,
            .foregroundColor:UIColor.black
        ]
        var girlImage = UIImage(named: "girl")!
        let width = textView.textContainer.size.width - 10.0
        let imageSize = CGSize(width: width, height: width * girlImage.size.height / girlImage.size.width)
        
        girlImage = girlImage.drawedInContainerFor(size: CGSize(width: imageSize.width, height: imageSize.height + 80.0), imageRect: .init(x: 0, y: 40, width: imageSize.width, height: imageSize.height))
        
        let pictureAttachment = NSTextAttachment.init(image: girlImage)
        
        /// textview 绘制文字并不是从0开始
      
        pictureAttachment.bounds = .init(x:0, y: 0, width:  width, height: width * girlImage.size.height / girlImage.size.width)

        let pictureAttriStr = NSMutableAttributedString.init(attachment: pictureAttachment)


        //构造显示富文本
        let displayAttri = NSMutableAttributedString.init(string: "Pretty Girl\nPretty Girl\n", attributes: attributes)
        displayAttri.append(pictureAttriStr)
        textView.attributedText  = displayAttri
    }
    
    
    func testUIControlContainer() {
        let redView = UIView(frame: .zero)
        let greenView = UIView(frame: .zero)
        let controlContainer = BuilderControl.init { v in
            redView.backgroundColor = .red
            greenView.backgroundColor = .green
            v.addSubview(redView)
            v.addSubview(greenView)
            v.backgroundColor = .gray
        }
        controlContainer.layoutSubviewsHandler = {
            v in
            redView.frame = .init(x: 0, y: 0, width: 0.2*v.bounds.width, height: v.bounds.height)
            greenView.frame = .init(x: 0.3 * v.bounds.width, y: 0, width: v.bounds.width, height: v.bounds.height)
        }
        controlContainer.setIsUserEnableForSubViews(false)
        
        ///手势监听,处理手势相关的UI变化
        controlContainer.touchEventListener = TouchEventListener(handler: {
            [weak controlContainer]
            state, touches, event in
            guard let cc = controlContainer else { return true }
            switch state {
            case .began:
                let maskV = UIView(frame: cc.bounds)
                maskV.layer.backgroundColor = UIColor(white: 1.0, alpha: 0.5).cgColor
                cc.mask = maskV
            case .moved:
                  break
            case .ended,.cancelled:
                cc.mask = nil
            }
            return true
        })
        view.addSubview(controlContainer)
        self.controlContainer = controlContainer
        
        controlContainer.addTargetAction(for: .touchUpInside) { sender, event in
            debugPrint(sender,event)
        }
    }
}




//MARK: - UI
extension ViewController {
    func setupUI() {
        textView.keyboardDismissMode = .onDrag
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: view.leftAnchor),
            textView.rightAnchor.constraint(equalTo: view.rightAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
