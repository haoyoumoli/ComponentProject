//
//  ModuleManager.swift
//  ModuleManager
//
//  Created by apple on 2022/2/14.
//

import Foundation

public protocol Module: AnyObject {
    
    init(parameter:Any)
    
    func getInterfaceImpl() -> Any 
}


public class ModuleManager {
    
    public static let shared = ModuleManager()
    
    public init() {}
    
    deinit {
        debugPrint("ModuleManager deinit")
    }
    
    lazy private var map:[String:Module] = [:]
    
    private struct LazyMuduleContext {
        let type:Module.Type
        let parameter:Any
    }
    lazy private var lazyMap:[String:LazyMuduleContext] = [:]
    
    public func regsisterModule(for name:String,
                                type:Module.Type,
                                parameter:Any,
                                lazy:Bool = false) {
        if name.isEmpty { return }
        if lazy == false {
            map[name] = type.init(parameter: parameter)
        } else {
            lazyMap[name] = LazyMuduleContext(type: type, parameter: parameter)
        }
    }
    
    public func removeModule(for name:String) {
        if name.isEmpty { return }
        map[name] = nil
        lazyMap[name] = nil
    }
    
    public func getInterfaceImp<T>(moduleName:String,interfaceType:T.Type) -> T?  {
        if moduleName.isEmpty { return nil }
        if let module = map[moduleName] {
            return module.getInterfaceImpl() as? T
        } else if let moduleContext = lazyMap[moduleName] {
            let module = moduleContext.type.init(parameter: moduleContext.parameter)
            map[moduleName] = module
            return module.getInterfaceImpl() as? T
        }
        return nil
    }
}
