//
//  APIManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/16.
//

import Foundation

final class APIManager {
    static let shared = APIManager()

    private struct Constants {
        static let apiKey = ""
        static let sandboxApiKey = ""
        static let baseURL = ""

    }

    // MARK: - Public


    // MARK: - Private
    private init () {}

    private enum Endpoint: String {
        case search
    }

    private enum APIError: Error {
        case noDataRecived
        case invaildURL
    }

    private func url(for endpoint: Endpoint, quaryParams: [String: String] = [:]) -> URL? {

        return nil
    }

    private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping(Result<T, Error>) -> Void){
        guard let url = url else {
            completion(.failure(APIError.invaildURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,  error == nil else {
                if let error = error {
                    completion(.failure(error))
                }else {
                    completion(.failure(APIError.noDataRecived))
                }
                return
            }
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }

    }


}
