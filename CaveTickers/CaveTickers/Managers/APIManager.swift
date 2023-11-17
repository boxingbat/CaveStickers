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
        static let apiKey = "clau1chr01qi1291dli0clau1chr01qi1291dlig"
        static let baseURL = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }

    // MARK: - Public

    public func search( query: String, completion: @escaping(Result<SearchResponse, Error>) -> Void) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed
        )else {return}
        request(url: url(for: .search, queryParams: ["q":query]),
                expecting: SearchResponse.self,
                completion: completion)
    }

    public func marketData(
        for symbol: String,
        numberOfDays: TimeInterval = 7,
        completion: @escaping (Result<MarketDataRespone, Error>) -> Void
    ) {
        let today = Date().addingTimeInterval(-(Constants.day))
        let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
        request(
            url: url(
                for: .marketData,
                queryParams: [
                    "symbol": symbol,
                    "resolution": "1",
                    "from": "\(Int(prior.timeIntervalSince1970))",
                    "to": "\(Int(today.timeIntervalSince1970))"
                ]
            ),
            expecting: MarketDataRespone.self,
            completion: completion
        )
    }



    // MARK: - Private
    private init () {}

    private enum Endpoint: String {
        case search
        case marketData = "stock/candle"
    }

    private enum APIError: Error {
        case noDataRecived
        case invaildURL
    }

    private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {

        var urlString = Constants.baseURL + endpoint.rawValue

        var queryItems = [URLQueryItem]()
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }

        queryItems.append(.init(name: "token", value: Constants.apiKey))

        urlString += "?" + queryItems.map{ "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")

        print("\n\(urlString)\n")

        return URL(string:  urlString)
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
        task.resume()
    }
}
