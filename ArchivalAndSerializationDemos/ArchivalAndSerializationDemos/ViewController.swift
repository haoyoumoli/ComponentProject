//
//  ViewController.swift
//  ArchivalAndSerializationDemos
//
//  Created by apple on 2022/2/17.
//

import UIKit

protocol DAOQueryExpress {
    func queryExpress() -> String
}

struct DAOQueryItem<Value> : DAOQueryExpress {
    func queryExpress() -> String {
        var result = "\(self.colum)"
        switch relationship {
        case .equalTo(value: let value):
            result.append("=\(value)")
        case .greatThan(value: let value):
            result.append(">\(value)")
        case .greatOrEqualTo(value: let value):
            result.append(">=\(value)")
        case .lessThan(value: let value):
            result.append("<\(value)")
        case .leasThanOrEqual(value: let value):
            result.append("<=\(value)")
        }
        return result
    }
    

    enum Relationship {
      case equalTo(value: Value)
      case greatThan(value:Value)
      case greatOrEqualTo(value:Value)
      case lessThan(value:Value)
      case leasThanOrEqual(value:Value)
    }
    
    let colum:String
    let relationship:Relationship
    
    init(_ colum:String,_ relationship:Relationship) {
        self.colum = colum
        self.relationship = relationship
    }
}




class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //demo1()
        //demo2()
        //demo3()
        
//        do {
//            let jsonDic = ["aaa":"AAA"]
//            let data = try JSONSerialization.data(withJSONObject: jsonDic, options: .fragmentsAllowed)
//            let model = try JSONDecoder().decode(Model.self, from: data)
//            let modelData = try JSONEncoder().encode(model)
//            let modelString = String.init(data: modelData, encoding: .utf8)
//            debugPrint(model,modelString)
//        } catch let err {
//            debugPrint(err)
//        }
      
//        let model = Model.init(aaa: "123")
//        debugPrint(model)

//       let item = DAOQueryItem("age", .lessThan(value: 4))
//       let item1 = DAOQueryItem("city", .equalTo(value: "'北京'"))
//        debugPrint(item.queryExpress(),item1.queryExpress())
        
        let linklist1 = LinkListNode.from(array: [1,3,5])!
        let linklist2 = LinkListNode.from(array: [2,4,6,8])!
        debugPrint(linklist1.last,linklist2.last)
        
        let linkList3 = LinkListNode.mergeSortedLinkList(l1: linklist1, l2: linklist2)
        debugPrint(linklist1.last,linklist2.last)
      
        
        let linklist4 = LinkListNode.from(other: linklist1)
        
        debugPrint(linklist1.last,linklist2.last)
        
        let linklist5 = LinkListNode.mergeSortedLinkListIteration(l1: linklist1, l2: linklist2)
        
        debugPrint(linklist1,linklist2,linkList3,linklist4,linklist5)
        
        debugPrint(linklist1.last,linklist2.last)
     
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



