//
//  NetworkingManager .swift
//  CaveTickers
//
//  Created by 1 on 2023/11/29.
//

import Foundation
import Combine

enum NetworkingManager {
    enum NetworkingError: LocalizedError {
        case badURLRespone(url: URL)
        case unknown

        var errorDescription: String? {
            switch self {
            case .badURLRespone(url: let url): return "Bad URL Respone from URL: \(url)"
            case .unknown: return "Unknow errpr occured"
            }
        }
    }

    static func download(url: URL) -> AnyPublisher<Data, any Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap({ try handleURLResponse(output: $0, url: url) })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    static func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            throw NetworkingError.badURLRespone(url: url)
        }
        return output.data
    }
    static func handleCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}
