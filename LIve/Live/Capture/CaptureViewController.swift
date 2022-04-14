//
//  CaptureViewController.swift
//  Live
//
//  Created by apple on 2022/3/28.
//

import UIKit
import SnapKit
import CoreMedia
import LFRtmp

class CaptureViewController: UIViewController {
    
    lazy private(set)
    var videoCamera:GPUImageVideoCamera? = {
        let result = GPUImageVideoCamera.init(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .front)
        result?.outputImageOrientation = .portrait
        result?.delegate = self
        return result
    }()
    
    //摄像头采集预览view
    lazy private(set)
    var capturePreview: GPUImageView = {
        let result = GPUImageView.init(frame: .zero)
        view.addSubview(result)
        return result
    }()
    
    
    lazy private(set)
    var h264Capture: GPUImageVideoCamera? = {
        let result = GPUImageVideoCamera
            .init(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .front)
        result?.outputImageOrientation = .portrait
        result?.delegate = self
        return result
    }()
    
    //h264编码然后再解码预览view
    lazy private(set)
    var h264Preview: GPUImageView = {
        let result = GPUImageView.init(frame: .zero)
        view.addSubview(result)
        return result
    }()
    
    lazy private(set)
    var pixelImageView: UIImageView = {
        let result = UIImageView()
        view.addSubview(result)
        return result
    }()
    
    lazy private(set)
    var actionsButton: UIButton = {
        let result = UIButton.init(type: .system)
        result.backgroundColor = UIColor.gray
        result.setTitle("操作", for: .normal)
        result.addTarget(self,action: #selector(actionsButtonTouched(_:)), for: .touchUpInside)
        view.addSubview(result)
        return result
    }()
    
    lazy private(set)
    var currentFilter:GPUImageFilter? = nil
    
    lazy private(set)
    var videoEncoder:H264Encoder =  {
        var encodeParam = Live.H264Encoder.EncodeParam()
        encodeParam.encodeWidth = 1280
        encodeParam.encodeHeight = 720
        encodeParam.bitRate = 1024 * 1024
        let result = Live.H264Encoder(encodeParam: encodeParam)
        return result
    }()
    
    lazy private(set)
    var h264Decoder = Live.H264Decoder.init()
    
    lazy private(set)
    var audioProcessQueue = DispatchQueue.init(label: "CaptureViewController.audioProcessQueue")
}


//MARK: - System
extension CaptureViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}
//MARK: - ActionsViewControllerDelegate
extension CaptureViewController:GPUImageVideoCameraDelegate {
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        //        if currentFilter != nil {
        //            guard let pixelBufferRef = currentFilter!.renderTarget else {
        //                return
        //            }
        //        } else  {
        //          //没有视频滤镜,直接处理buffer
        //        }
        
        if !videoEncoder.encodeSampleBuffer(sampleBuffer, forceKeyFrame: false) {
            debugPrint("视频编码失败")
        }
    }
}

//MARK: - VEVideoEncoderDelegate
extension CaptureViewController : H264EncoderDelegate {
    func H264Encoder(_ encoder: H264Encoder, didEncodedData data: Data, isKeyFrame: Bool) {
        h264Decoder.decode(naluData: data)
    }
}


//MARK: - H264DecoderDelegate
extension CaptureViewController: H264DecoderDelegate {
    func H264Decoder(_ decoder:H264Decoder,didDecompress pixelBuffer:CVImageBuffer, sampleBuffer:CMSampleBuffer) {
        
        //        //只用cpu将pixelbuffer 转化为UIImage,不推荐,这样非常耗费性能,要从GPU显存中拷贝数据到内存由
        //        //cpu处理
        //        guard let image = pixelBuffer.toImage3() else {
        //            debugPrint("image == nil")
        //            return
        //        }
        //
        //        DispatchQueue.main.async {
        //            self.pixelImageView.image = image
        //        }
        
        //使用GPUImage显示解码后的h264数据
        h264Capture?.processVideoSampleBuffer(sampleBuffer)
    }
}

//MARK: - ActionsViewControllerDelegate
extension CaptureViewController:ActionsViewControllerDelegate {
    func actionsViewController(_ actionsViewController: ActionsViewController, didSelectedAction action: ActionsViewController.Action) {
        switch  action {
        case .switchCameraPosition:
            videoCamera?.rotateCamera()
        case .bilateralFilter:
            let bilateralFilter = GPUImageBilateralFilter.init()
            applyFilter(bilateralFilter)
        }
    }
}

//MARK: - AVCaptureAudioDataOutputSampleBufferDelegate
extension CaptureViewController: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        debugPrint(#function)
    }
}

//MARK: - Private
private extension CaptureViewController {
    
    func applyFilter(_ filter:GPUImageFilter) {
        //处理链 videocamera -> filter(group) -> gpuimageview
        currentFilter = nil
        videoCamera?.removeAllTargets()
        filter.addTarget(capturePreview)
        videoCamera?.addTarget(filter)
        currentFilter = currentFilter
    }
    
    func setup() {
        DispatchQueue.main.async { [self] in
            //布局
            capturePreview.snp.makeConstraints { make in
                make.left.top.equalToSuperview()
                make.right.equalTo(h264Preview.snp.left).offset(-5.0)
                make.bottom.equalTo(actionsButton.snp.top)
            }
            
            h264Preview.backgroundColor = .red
            h264Preview.snp.makeConstraints { make in
                make.top.right.equalToSuperview()
                make.bottom.equalTo(actionsButton.snp.top)
                make.width.equalTo(capturePreview)
            }
            
            //            pixelImageView.snp.makeConstraints { make in
            //                make.edges.equalTo(h264Preview)
            //            }
            
            actionsButton.snp.makeConstraints { make in
                make.height.equalTo(50.0)
                make.left.bottom.right.equalToSuperview()
            }
          
            h264Capture?.addTarget(h264Preview)
            
            setupCapture()

            videoEncoder.delegate = self
            h264Decoder.delegate = self
        }
    }
    
    func setupCapture() {
        //视频捕获输出到preview上
        videoCamera?.addTarget(capturePreview)
        //添加音频捕获
//        videoCamera?.captureSession.beginConfiguration()
//        if
//            let micophone = AVCaptureDevice.default(for: .audio),
//            let audioInput = try? AVCaptureDeviceInput.init(device: micophone),
//            videoCamera?.captureSession.canAddInput(audioInput) == true
//        {
//            let output = AVCaptureAudioDataOutput.init()
//            output.setSampleBufferDelegate(self, queue: audioProcessQueue)
//            if videoCamera?.captureSession.canAddOutput(output) == true {
//                videoCamera?.captureSession.addInput(audioInput)
//                videoCamera?.captureSession.addOutput(output)
//                debugPrint("成功添加音频捕获")
//            }
//        }
//        videoCamera?.captureSession.commitConfiguration()
        //开始捕获
        videoCamera?.startCapture()
    }
    
    @objc
    func actionsButtonTouched(_ sender:UIButton) {
        let actionsViewController = ActionsViewController()
        actionsViewController.modalPresentationStyle = .formSheet
        actionsViewController.delegate = self
        present(actionsViewController, animated: true, completion: nil)
    }
}
