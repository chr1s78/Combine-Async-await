//
//  CombineAsyncApp.swift
//  CombineAsync
//
//  Created by Chr1s on 2022/4/13.
//

import SwiftUI

@main
struct CombineAsyncApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .onAppear {
                    // 去除多余的打印信息
                    UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                }
        }
    }
}
