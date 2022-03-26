//
//  ListModel.swift
//  HomeProject
//
//  Created by apple on 2022/3/19.
//

import Foundation

struct ListModel<ItemType,ItemData> {
    
    let itemType:ItemType
    
    let itemData:ItemData
    
    init(itemType:ItemType,itemData:ItemData) {
        self.itemType = itemType
        self.itemData = itemData
    }
}
