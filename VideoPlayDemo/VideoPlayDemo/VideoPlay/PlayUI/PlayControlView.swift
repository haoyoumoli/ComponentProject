//
//  PlayControlView.swift
//  AVFoundationDemo
//
//  Created by apple on 2022/1/24.
//

import UIKit

//MARK: - Define
class PlayControlView:UIView {
    
    let playPauseBtn = UIButton.init(type: .system)
    let slider = UISlider()
    
    weak var delegate: PlayControlViewDelegate? = nil
    
    private(set) var state:State = .notPlayable
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        addSubview(playPauseBtn)
        addSubview(slider)
        
        playPauseBtn.setTitle("播放", for: .normal)
        playPauseBtn.setTitle("暂停", for: .selected)
        playPauseBtn.addTarget(self, action: #selector(playOrPauseBtnTouched(_:)), for: .touchUpInside)
        
        slider.minimumTrackTintColor = UIColor.blue
        slider.maximumTrackTintColor = UIColor.gray
        slider.thumbTintColor = UIColor.red
        slider.value = 0.0
        slider.maximumValue = 1.0
        slider.minimumValue = 0.0
        slider.addTarget(self, action: #selector(sliderDidStartDrag(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchedEnd(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
   
        
        chageState(to: .notPlayable)
        
    }
    
    
}

//MARK: - SubTypes

protocol PlayControlViewDelegate: NSObjectProtocol {
    
    func didPlay(view:PlayControlView)
    
    func didPause(view:PlayControlView)
    
    func didStartDragSlider(view:PlayControlView)
    
    func playControlView(view:PlayControlView,dragingSlider value:Float)
    
    func playControlView(view:PlayControlView,silderDragEnd current:Float,max:Float)
}

extension PlayControlView {
    enum State {
        case notPlayable
        case playable
        case playing
    }
}

//MARK: - Override
extension PlayControlView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        slider.frame = .init(x: 20, y: 10, width: bounds.width - 20 * 2 , height: 30)
        
        
        playPauseBtn.frame = .init(x: (bounds.width - 50) * 0.5, y: (bounds.height - 40) - 10, width: 50, height: 40)
        
        
    }
}


//MARK: - Interface
extension PlayControlView {
    
    func setPlayable(_ isPlayable: Bool) {
        chageState(to: isPlayable ? .playable : .notPlayable)
    }
    
    func changeToPlayUI() {
        chageState(to: .playing)
    }
    
    func changeToPauseUI() {
        chageState(to: .playable)
    }
    
    func setProgress(_ value:Float) {
        slider.setValue(value, animated: true)
    }
}

//MARK: - Private
private extension PlayControlView {
    
    func chageState(to state:State) {
        let old = self.state
        var needChangeState = true
        switch (old,state) {
        case (_ ,.notPlayable):
            playPauseBtn.isEnabled = false
            playPauseBtn.isSelected = false
        case (.notPlayable,.playable):
            playPauseBtn.isEnabled = true
            playPauseBtn.isSelected = false
        case (.playable,.playing):
            playPauseBtn.isSelected = true
        case (.playing,.playable):
            playPauseBtn.isSelected = false
        default:
            debugPrint("\(#function) 状态流转不符合预期 \(old) \(state)")
            needChangeState = false
        }
        if needChangeState {
            self.state = state
        }
        
    }
    
    @objc func sliderDidStartDrag(_ sender:UISlider) {
        delegate?.didStartDragSlider(view: self)
    }
    
    @objc func sliderTouchedEnd(_ sender:UISlider) {
        
        delegate?.playControlView(view: self, silderDragEnd: sender.value, max: sender.maximumValue)
    }
    
    @objc func sliderValueChanged(_ sender:UISlider) {
        delegate?.playControlView(view: self, dragingSlider: sender.value)
    }
    
    @objc func playOrPauseBtnTouched(_ sender:UIButton) {
        if sender.isSelected == false {
            //未播放
            chageState(to: .playing)
            delegate?.didPlay(view: self)
        } else  {
            chageState(to: .playable)
            delegate?.didPause(view: self)
            
        }
    }
}


