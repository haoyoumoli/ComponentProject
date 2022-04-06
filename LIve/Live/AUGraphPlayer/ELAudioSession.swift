//
//  ELAudioSession.swift
//  Live
//
//  Created by apple on 2022/4/2.
//

import Foundation
import AVFAudio

class ELAudioSession {
    
    enum  PreferredLatency:TimeInterval {
        case low = 0.0058
        case `default` = 0.0232
        case background = 0.0929
    }
    
    static var shared = ELAudioSession()
    
    let audioSession:AVAudioSession
    init() {
        audioSession = AVAudioSession.sharedInstance()
    }
    
    lazy private(set)
    var preferredLatency:PreferredLatency? = nil
    
    lazy private(set)
    var active:Bool? = nil
    
    lazy private(set)
    var catetory:AVAudioSession.Category? = nil
    
    lazy private(set)
    var preferredSampleRate:Double = 44100.0
    
}


//MARK: - ELAudioSession Interface

extension ELAudioSession {

    func set(preferredLatency:PreferredLatency) throws {
        self.preferredSampleRate  = preferredSampleRate
        try audioSession.setPreferredIOBufferDuration(preferredLatency.rawValue)
    }

    func set(category:AVAudioSession.Category) throws {
        self.catetory = catetory
        try audioSession.setCategory(category)
    }
    
    func set(active:Bool) throws {
        self.active  = active
        try audioSession.setPreferredSampleRate(preferredSampleRate)
        try audioSession.setActive(active, options: [])
    }
    
    func addRouteChangeListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(onRouteChange(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        adjustOnRouteChange()
    }
}

//MARK: -
fileprivate
extension ELAudioSession {
    @objc func onRouteChange(_ noti:NSNotification) {
        adjustOnRouteChange()
    }
    
    func adjustOnRouteChange() {
        if audioSession.getIsUsingWiredMicrophone() == false,
           audioSession.getIsUsingBlueTooth() == true
         {
            try? audioSession.overrideOutputAudioPort(.speaker)
       }
    }
}


//MARK: -
extension AVAudioSession {
    func getIsUsingBlueTooth() -> Bool {
        let ports = [AVAudioSession.Port.bluetoothHFP]
        return getIsInputUsing(ports: ports) || getIsOutputUsing(ports: ports)
        
       
    }
    
    func getIsUsingWiredMicrophone() -> Bool {
        let inputPorts = [AVAudioSession.Port.headsetMic]
        let outputPorts = [AVAudioSession.Port.headphones,AVAudioSession.Port.usbAudio]
        return getIsInputUsing(ports: inputPorts) || getIsOutputUsing(ports: outputPorts)
    }
    
    
    func shouldShowEarphoneAlert() -> Bool {
        return getIsOutputUsing(ports: [.builtInReceiver,.builtInSpeaker])
    }
    
    private
    func getIsInputUsing(ports:[AVAudioSession.Port]) -> Bool {
        let inputs = self.currentRoute.inputs
        if inputs.contains(where: { desc in
            return ports.contains(where: { desc.portType == $0 })
        }) == true {
            return true
        }
        return false
    }
    
    private
    func getIsOutputUsing(ports:[AVAudioSession.Port]) -> Bool {
        let outputs = self.currentRoute.outputs
        if outputs.contains(where: {
            desc in
            return ports.contains(where: { $0 == desc.portType})
        }) == true {
            return true
        }
        return false
    }
}


