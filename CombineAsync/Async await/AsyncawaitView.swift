//
//  AsyncawaitView.swift
//  CombineAsync
//
//  Created by Chr1s on 2022/4/13.
//

import SwiftUI

struct AsyncawaitView: View {
    
    @StateObject var vm = ViewModel(service: NetworkService())
 
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(vm.posts) { post in
                    Text("\(post.id): " + post.title)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Async await")
        .alert(isPresented: $vm.hasError) {
            Alert(title: Text("Error"), message: Text(vm.errorMsg), dismissButton: .default(Text("OK")))
        }
        .toolbar(content: {
            ToolbarItem {
                HStack {
                    Text("Load")
                        .onTapGesture {
                            Task {
                                await vm.fetchData() 
                            }
                        }
                }
            }
        })
        
    }
}

extension AsyncawaitView {
    
    @MainActor
    class ViewModel: ObservableObject {

        @Published var posts: [PostModel] = []
        @Published var errorMsg: String = ""
        @Published var hasError: Bool = false
        
        var index: Int = 0
        
        private let service: NetworkService
        
        init(service: NetworkService) {
            self.service = service
        }
        
        func fetchData() async {
            index += 1
            do {
                let data = try await service.fetchPostWithConcurrency(index: index)
                self.hasError = false
                self.posts.append(data)
            } catch(let error) {
                self.hasError = true
                self.errorMsg = (error as? NetworkError)?.description ?? error.localizedDescription
            }
        }
        
    }
}

struct AsyncawaitView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncawaitView()
    }
}
