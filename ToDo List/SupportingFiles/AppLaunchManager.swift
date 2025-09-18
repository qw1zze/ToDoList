//
//  AppLaunchManager.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 18/9/25.
//

import Foundation

class AppLaunchManager {
    static let shared = AppLaunchManager()
    
    private let key = "isFirstLaunch"
    
    private init() {}
    
    var isFirstLaunch: Bool {
        get {
            !UserDefaults.standard.bool(forKey: key)
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: key)
        }
    }
    
    func markAsLaunched() {
        isFirstLaunch = false
    }
}
