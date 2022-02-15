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
    
    init() {}
    
    deinit {
        debugPrint("ModuleManager deinit")
    }
    
    lazy private var map:[String:Module] = [:]
    
    private struct LazyMuduleContext {
        let type:Module.Type
        let parameter:Any
    }
    
    lazy private var lazyMap:[String:LazyMuduleContext] = [:]
}


//MARK: - 对外接口
extension ModuleManager {
    
    //单例
    public static let shared = ModuleManager()
    
    
    /// 注册模块
    /// - Parameters:
    ///   - name: 模块的名称
    ///   - type: 模块的类型
    ///   - parameter: 模块初始化所需参数
    ///   - lazy: 是否懒加载,如果是懒加载,则在请求模块接口实现时初始化模块,否则在这个方法中直接初始化模块
    public func regsisterModule(for name:String,
                                type:Module.Type,
                                parameter:Any,
                                lazy:Bool = true) {
        if name.isEmpty { return }
        if lazy == false {
            map[name] = type.init(parameter: parameter)
        } else {
            lazyMap[name] = LazyMuduleContext(type: type, parameter: parameter)
        }
    }
    
    
    /// 移除模块
    /// - Parameter name: 模块的名称
    public func removeModule(for name:String) {
        if name.isEmpty { return }
        map[name] = nil
        lazyMap[name] = nil
    }
    
    
    /// 获取模块的接口
    /// - Parameters:
    ///   - moduleName:模块名称
    ///   - interfaceType:接口协议类型
    /// - Returns: 返回实现了模块接口的实例
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
