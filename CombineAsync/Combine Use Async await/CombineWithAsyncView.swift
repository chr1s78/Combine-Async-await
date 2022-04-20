//
//  CombineWithAsyncView.swift
//  CombineAsync
//
//  Created by Chr1s on 2022/4/14.
//

import SwiftUI
import Combine

struct CombineWithAsyncView: View {
    
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
        .navigationTitle("Combine use Async")
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

extension CombineWithAsyncView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published var posts: [PostModel] = []
        @Published var errorMsg: String = ""
        @Published var hasError: Bool = false
        
        var cancellables = Set<AnyCancellable>()
        var loadSubject = CurrentValueSubject<Void, Never>(())
  
        static var index: Int = 0
        private let service: NetworkService
        
        init(service: NetworkService) {
            
            self.service = service
          
            loadSubject
                .flatMap { _ -> Future<PostModel, Error> in
                    ViewModel.index += 1
                    return Future { promise in
                        Task {
                            do {
                                let data = try await service.fetchPostWithConcurrency(index: ViewModel.index)
                                promise(.success(data))
                            } catch {
                                promise(.failure(error as? NetworkError ?? .unknown))
                            }
                        }
                    }
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

struct CombineWithAsyncView_Previews: PreviewProvider {
    static var previews: some View {
        CombineWithAsyncView()
    }
}
