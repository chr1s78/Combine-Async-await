//
//  HomeView.swift
//  CombineAsync
//
//  Created by Chr1s on 2022/4/13.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            List {
                
                NavigationLink("Use Async&await") {
                    AsyncawaitView()
                }
                
                NavigationLink("Use Combine") {
                    CombineView()
                }
                
                NavigationLink("Combine Use Async&await") {
                    CombineWithAsyncView()
                }
                
                NavigationLink("Async&await Use Combine") {
                    AsyncWithCombineView()
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
