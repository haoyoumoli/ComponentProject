//
//  ViewController.swift
//  ArchivalAndSerializationDemos
//
//  Created by apple on 2022/2/17.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //demo1()
        //demo2()
        //demo3()
        
        do {
            let jsonDic = ["aaa":"AAA"]
            let data = try JSONSerialization.data(withJSONObject: jsonDic, options: .fragmentsAllowed)
            let model = try JSONDecoder().decode(Model.self, from: data)
            let modelData = try JSONEncoder().encode(model)
            let modelString = String.init(data: modelData, encoding: .utf8)
            debugPrint(model,modelString)
        } catch let err {
            debugPrint(err)
        }
      
//        let model = Model.init(aaa: "123")
//        debugPrint(model)
       
    }


}



@propertyWrapper
struct DefaultValue<T:Codable> {

    private var storage:T
    
    init(_ storage:T) {
        self.storage = storage
    }
    
    var wrappedValue:T {
        get { return storage }
        set { storage = newValue}
    }
}

 
extension DefaultValue:Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        storage = try container.decode(T.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}




struct Model: Codable {
    @DefaultValue("")
    var aaa:String
    
    init(
        aaa:String = ""
    ) {
        self.aaa = aaa
    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        aaa = try container.decodeIfPresent(String.self, forKey: .aaa) ?? ""
//    }
}
