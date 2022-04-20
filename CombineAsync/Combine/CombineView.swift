//
//  CombineView.swift
//  CombineAsync
//
//  Created by Chr1s on 2022/4/14.
//

import SwiftUI
import Combine

struct CombineView: View {
    
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
        .navigationTitle("Combine")
        .alert(isPresented: $vm.hasError) {
            Alert(title: Text("Error"), message: Text(vm.errorMsg), dismissButton: .default(Text("OK")))
        }
        .toolbar(content: {
            ToolbarItem {
                HStack {
                    Text("Load")
                        .onTapGesture {
                            vm.loadSubject.send(0)
                        }
                }
            }
        })
    }
}

extension CombineView {
    class ViewModel: ObservableObject {
        
        @Published var posts: [PostModel] = []
        @Published var errorMsg: String = ""
        @Published var hasError: Bool = false
        
        var cancellables = Set<AnyCancellable>()
        var loadSubject = CurrentValueSubject<Int, Never>(0)
        
        var index: Int = 0
        
        private let service: NetworkService
        
        init(service: NetworkService) {
            self.service = service
            
            loadSubject
                .flatMap { [weak self] _ -> AnyPublisher<PostModel, Error> in
                    self?.index += 1
                    return service.fetchPostWithCombine(index: self!.index)
                }
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.hasError = false
                    case .failure(let error):
                        self?.hasError = true
                        self?.errorMsg = (error as? NetworkError)?.description ?? error.localizedDescription
                    }
                } receiveValue: { [weak self] value in
                    self?.posts.append(value)
                }
                .store(in: &cancellables)

                
        }
    }
}

struct CombineView_Previews: PreviewProvider {
    static var previews: some View {
        CombineView()
    }
}
