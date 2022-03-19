//
//  KVOObserver.swift
//  AVFoundationDemo
//
//  Created by apple on 2022/1/20.
//

import Foundation

class KVOManager: NSObject {
    
    lazy private(set)
    var ctxList:[KVOContext] = []
    
    deinit {
        unobserveAll()
    }
    
    func observe(
        for object:NSObject,
        of keyPath:String,options:NSKeyValueObservingOptions,
        context:UnsafeMutableRawPointer?,
        callback: @escaping KVOCallBack
    ) {
        let ctx = KVOContext.init(observed: object, keypath: keyPath, options: options, context: context,callBack: callback)
        ctxList.append(ctx)
        object.addObserver(self, forKeyPath: keyPath, options: options, context: context)
    }
    
    func unobserve(
        for object:NSObject,
        of keyPath:String,
        context:UnsafeMutableRawPointer?
    ) {
       
        let result = ctxList.filter({
            $0.matched(object: object, keypath: keyPath, context: context)
        })
        removeObserver(for: result)
        ctxList = ctxList.lazy.filter({
            !$0.matched(object: object, keypath: keyPath, context: context)
        })
    }
 
    func unobserveAll() {
        removeObserver(for: ctxList)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard
            let kp = keyPath,
            let nsobjc = object as? NSObject
        else { return }
        
        for ctx in ctxList {
            if  ctx.matched(object: nsobjc, keypath: kp, context: context) {
                ctx.callBack(ctx,change)
            }
        }
    }
}

//MARK: - Subtype
extension KVOManager {
    class KVOContext {
        weak private(set) var observed:NSObject?
        let keypath:String
        let options:NSKeyValueObservingOptions
        let context:UnsafeMutableRawPointer?
        fileprivate let callBack:KVOCallBack
        
        
       init(
        observed:NSObject?,
        keypath:String,
        options:NSKeyValueObservingOptions,
        context:UnsafeMutableRawPointer?,
        callBack: @escaping KVOCallBack
       ) {
           self.observed = observed
           self.keypath = keypath
           self.options = options
           self.context = context
           self.callBack = callBack
       }
        
        func matched
        (object:NSObject,
         keypath:String,
         context:UnsafeMutableRawPointer?
        ) -> Bool {
            return observed == object && self.keypath == keypath && self.context == context
        }
    }
    
    typealias KVOCallBack = (KVOContext,[NSKeyValueChangeKey : Any]?) -> Void
}


//MARK: - private
private
extension KVOManager {
    func removeObserver(for contextList:[KVOContext]) {
        for ctx in contextList {
            ctx.observed?.removeObserver(self, forKeyPath: ctx.keypath,context: ctx.context)
        }
    }
}
