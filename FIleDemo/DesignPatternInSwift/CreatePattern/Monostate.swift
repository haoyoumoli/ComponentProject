//
//  Monostate.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/19.
//

import Foundation

///单态（Monostate）
///单态模式是实现单一共享的另一种方法。不同于单例模式，它通过完全不同的机制，在不限制构造方法的情况下实现单一共享特性。 因此，在这种情况下，单态会将状态保存为静态，而不是将整个实例保存为单例。 单例和单态 - Robert C. Martin


class Settings {
    enum Theme {
        case `default`
        case old
        case new
    }
    
    private static var theme: Theme?
    
    var currentTheme: Theme {
        get { Settings.theme ?? .default }
        set { Settings.theme = newValue }
    }
}

func testMonostate() {
    let settings = Settings()
    settings.currentTheme = .new
    
    let screenColor = settings.currentTheme == .old ? "gray" : "yellow"
    
    let screenTitle = Settings().currentTheme == .default ? "123" : "456"
    
    debugPrint((screenColor,screenTitle))
    
}
