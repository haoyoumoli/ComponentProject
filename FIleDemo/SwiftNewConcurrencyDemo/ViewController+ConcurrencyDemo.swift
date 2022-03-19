//
//  ViewController+ConcurrencyDemo.swift
//  SwiftNewConcurrencyDemo
//
//  Created by apple on 2021/9/23.
//

import Foundation
import UIKit

//MARK: - demos
@available(iOS 15.0.0, *)
extension ViewController {
    
    
    
    
    struct Meal {
        
    }
    
    struct Vegetable {
        
    }
    
    struct Meat {
        
    }
    
    struct Oven {
        func cook(dish:Dish,duration:Double) async throws -> Meal {
            return Meal()
        }
    }
    
    struct Dish {
        let ingredients:[Any]
        init(ingredients:[Any]) {
            self.ingredients = ingredients
        }
        
    }
    
    func makeDinner() async throws -> Meal {
        var veggies:[Vegetable]?
        var meat:Meat?
        var oven: Oven?
        
        enum CookingStep {
            case veggies([Vegetable])
            case meat(Meat)
            case oven(Oven)
        }
        
        try await withThrowingTaskGroup(of: CookingStep.self, body: { group in
            group.addTask {
                try await .veggies(self.chopVegetables())
            }
           
            
            group.addTask {
                await .meat(self.marinateMeat())
            }
            
            
            group.addTask {
                try await .oven(self.preheatOven(temperature: 350))
            }
            
           
            
            
            for try await finishedStep in group {
                switch finishedStep {
                    
                case .veggies(let v):
                    veggies = v
                case .meat( let  m):
                    meat = m
                    
                case .oven(let o ):
                    oven = o
                }
            }
        })
        
        let dish = Dish(ingredients: [veggies!,meat!])
        return try await oven!.cook(dish: dish, duration: 3.0)
        
    }
    
    
    ///切菜
    func chopVegetables() async throws -> [Vegetable] {
        
        try Task.checkCancellation()
        
        let url = URL(string: "https://www.baidu.com")!
        let request = URLRequest(url: url)
        let result = try await URLSession.shared.data(for: request, delegate: nil)
        debugPrint(result)
        return []
    }
    
    ///腌肉
    func marinateMeat() async -> Meat {
        
       let task = Task.init(priority: nil) {
            return "AAA"
        }
        
        debugPrint(task)
        
        return Meat()
    }
    
    
    ///预热烤箱
    func preheatOven(temperature:Double) async throws -> Oven {
        return Oven()
    }
}

