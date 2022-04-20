//
//  AsyncWithCombine.swift
//  CombineAsync
//
//  Created by Chr1s on 2022/4/14.
//

import SwiftUI
import Combine

struct AsyncWithCombineView: View {
    
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
        .navigationTitle("Async Use Combine")
        .alert(isPresented: $vm.hasError) {
            Alert(title: Text("Error"), message: Text(vm.errorMsg), dismissButton: .default(Text("OK")))
        }
        .toolbar(content: {
            ToolbarItem {
                HStack {
                    Text("Load")
                        .onTapGesture {
                            vm.loadSubject.send()
                        }
                }
            }
        })
    }
}

extension AsyncWithCombineView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published var posts: [PostModel] = []
        @Published var errorMsg: String = ""
        @Published var hasError: Bool = false
        
        var cancellables = Set<AnyCancellable>()
        var loadSubject = CurrentValueSubject<Void, Never>(())
        
        var index: Int = 0
  
        private let service: NetworkService
        
        init(service: NetworkService) {
            self.service = service
            
            Task {
                for await _ in loadSubject.values {
                    self.index += 1
                    
                    do {
                        let data = try await service.fetchPostWithConcurrency(index: self.index)
                        self.hasError = false
                        self.posts.append(data)
                    } catch {
                        self.hasError = true
                        self.errorMsg = (error as? NetworkError)?.description ?? error.localizedDescription
                    }
                }
            }
        }
    }
}


struct AsyncWithCombine_Previews: PreviewProvider {
    static var previews: some View {
        AsyncWithCombineView()
    }
}
