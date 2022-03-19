//
//  ViewController.swift
//  PropertyCodeableDemo
//
//  Created by apple on 2021/5/17.
//
// 链接地址: https://blog.csdn.net/sinat_35969632/article/details/109635022

import UIKit


struct Video:Decodable {
    let id: Int
    
    @Default.EmptyString
    var title: String
    
    @Default.True
    var commentEnabled:Bool
    
    enum State: String,Decodable {
        case streaming
        case archived
        case unknown
    }
    
    @Default<State>
    var state:State
    

    ///有了属性包装, 可以不用下面的代码了
    //    enum CodingKeys:String,CodingKey {
    //        case id,title, commentEnabled,state
    //    }
    
    //    init(from decoder: Decoder) throws {
    //        let container = try  decoder.container(keyedBy: CodingKeys.self)
    //        id = try container.decode(Int.self, forKey: .id)
    //        title = try container.decode(String.self, forKey: .title)
    //
    //        ///提供默认值
    //        commentEnabled = try container.decodeIfPresent(Bool.self, forKey: .commentEnabled) ?? false
    //
    //        state = try container.decode(State.self, forKey: .state)
    //    }
}

///为State类型设置默认值为 unknown
extension Video.State:DefaultValue {
    static let defaultValue:Video.State = .unknown
}



@propertyWrapper
final class Yellow {
    var wrappedValue = "Yellow"
    
    init(wrappedValue: String) {
        debugPrint("init wrappedValue:\(wrappedValue)")
        self.wrappedValue = "Yellow"
    }
    
    ///这个属性表示映射的值,使用$取得这个属性
    ///必须要有这个属性才可以使用 $调用包装器的方法
    var projectedValue: Yellow { self }

    func www() {
        debugPrint("www")
        wrappedValue =  wrappedValue.appending(wrappedValue)
    }
    
    var xxx = "xxx"
}

//MARK:-

class ViewController: UIViewController {
    
    @Yellow
    var yellow:String = "546"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        debugPrint(yellow)
        debugPrint($yellow.xxx)
        debugPrint($yellow.www())
        debugPrint(yellow)
        
        yellow = "green"
        debugPrint(yellow)
        debugPrint($yellow.xxx)
        debugPrint($yellow.www())
        debugPrint(yellow)
        
        //decodeVideo(for: "{\"id\":123456}".data(using: .utf8)!,label: "测试必要字段的解码")
        
        decodeVideo(for: "{\"id\":123456,\"title\":\"MY First Video\",\"state\":\"archived\",\"commentEnabled\":true}".data(using: .utf8)!,label: "带bool的解码:true")
        
        decodeVideo(for: "{\"id\":123456,\"title\":\"MY First Video\",\"state\":\"archived\",\"commentEnabled\":false}".data(using: .utf8)!,label: "带bool的解码:false")
        
        decodeVideo(for: "{\"id\":123456,\"title\":\"MY First Video\",\"state\":\"archived\",\"commentEnabled\":1}".data(using: .utf8)!,label: "带bool的解码:true 1")
        
        decodeVideo(for: "{\"id\":123456,\"title\":\"MY First Video\",\"state\":\"archived\",\"commentEnabled\":0}".data(using: .utf8)!,label: "带bool的解码:false 0")
        
        
        decodeVideo(for: "{\"id\":123456,\"title\":\"MY First Video\",\"state\":\"archived\",\"commentEnabled\":\"true\"}".data(using: .utf8)!,label: "带bool的解码:'true'")
        
        decodeVideo(for: "{\"id\":123456,\"title\":\"MY First Video\",\"state\":\"archived\",\"commentEnabled\":\"false\"}".data(using: .utf8)!,label: "带bool的解码:'false'")
        
        decodeVideo(for: "{\"id\":123456,\"title\":\"MY First Video\",\"state\":\"archived\"}".data(using: .utf8)!,label: "带状态的解码 archived")
        
        decodeVideo(for: "{\"id\":123456,\"title\":\"MY First Video\",\"state\":\"reserved\"}".data(using: .utf8)!,label: "带枚举之外的状态的解码")
    }
    
    
    func decodeVideo(for data:Data,label:String) {
        let decoder = JSONDecoder.init()
        debugPrint()
        debugPrint(label)
        if let video = try? decoder.decode(Video.self, from: data) {
            
            debugPrint(video)
        } else {
            debugPrint("解码失败")
        }
    }
    
    
}

