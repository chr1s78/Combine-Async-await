//
//  NetworkService.swift
//  CombineAsync
//
//  Created by Chr1s on 2022/4/13.
//

import Foundation
import Combine

enum NetworkError: Error, CustomStringConvertible {

    case badURL
    case badResponse
    case badDecode
    case unknown

    var description: String {
        switch self {
        case .badURL:
            return "网络错误"
        case .badResponse:
            return "请求响应错误:"
        case .badDecode:
            return "解码错误"
        case .unknown:
            return "未知错误"
        }
    }
}

struct NetworkService {
    
    func fetchPostWithCombine(index: Int) -> AnyPublisher<PostModel, Error> {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/" + "\(index)") else {
            return Fail(error: NetworkError.badURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                          throw NetworkError.badResponse
                }
                return element.data
            }
            .decode(type: PostModel.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                switch error {
                case is URLError:
                    return .badURL
                case is DecodingError:
                    return .badDecode
                default:
                    return error as? NetworkError ?? .unknown
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchPostWithConcurrency(index: Int) async throws -> PostModel {
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/\(index)")!
                
        guard let (data, response) = try? await URLSession.shared.data(from: url) else {
            throw NetworkError.badURL
        }
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
                  throw NetworkError.badResponse
              }
        
        guard let decodedData = try? JSONDecoder().decode(PostModel.self, from: data) else {
            throw NetworkError.badDecode
        }
        return decodedData
    }
}
