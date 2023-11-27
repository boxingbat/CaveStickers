//
//  APIManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/16.
//

import Foundation

final class APIManager {
    static let shared = APIManager()
    enum Constants {
        static let finApiKey = "clau1chr01qi1291dli0clau1chr01qi1291dlig"
        static let finBaseURL = "https://finnhub.io/api/v1/"
        static let alphaApiKey = ["0YAY61FY4TXJKQ34", "VR8XWYY9Y4R3QDFL", "PMGWPTBCGY4EZTWD", "UI3PDP3K22181YEN", "5RGL2QT6AWAUS9PU"]
        static let alphaBaseURL = "https://www.alphavantage.co/query?function="
        static let day: TimeInterval = 3600 * 24
    }

    // MARK: - Public
    public func search(query: String, completion: @escaping(Result<SearchResponse, Error>) -> Void) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        request(
            url: finUrl(for: .search, queryParams: ["q": safeQuery]),
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
            url: finUrl(
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
    public func financialMetrics(
        for symbol: String,
        completion: @escaping (Result<FinancialMetricsResponse, Error>) -> Void
    ) {
        request(
            url: finUrl(
                for: .financials,
                queryParams: ["symbol": symbol, "metric": "all"]
            ),
            expecting: FinancialMetricsResponse.self,
            completion: completion
        )
    }
    public func monthlyAdjusted(
        for symbol: String,
        keyNumber: Int,
        completion: @escaping (Result<TimeSeriesMonthlyAdjusted, Error>) -> Void
    ) {
        let apikey = Constants.alphaApiKey[keyNumber]
        request(
            url: alphaURL(for: symbol, apiKey: apikey),
            expecting: TimeSeriesMonthlyAdjusted.self,
            completion: completion
        )
    }
    public func news(completion: @escaping (Result<[NewsStory], Error>) -> Void) {
        request(
            url: finUrl(for: .topStories, queryParams: ["category": "general"]),
            expecting: [NewsStory].self,
            completion: completion
        )
    }
    public func companyNews(symbol: String, completion: @escaping (Result<[NewsStory], Error>) -> Void) {
        let today = Date()
        let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
        request(
            url: finUrl(for: .companyNews,
                    queryParams: [
                            "symbol": symbol,
                            "from": DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                            "to": DateFormatter.newsDateFormatter.string(from: today)
                        ]
                    ),
            expecting: [NewsStory].self,
            completion: completion
        )
    }
    // MARK: - Private
    private init () {}

    private enum Endpoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
        case monthlyAddjusted = "TIME_SERIES_MONTHLY_ADJUSTED&"
    }
    private enum APIError: Error {
        case noDataRecived
        case invaildURL
    }
    private func finUrl(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
        var urlString = Constants.finBaseURL + endpoint.rawValue
        print(urlString)
        var queryItems: [URLQueryItem] = []
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        queryItems.append(.init(name: "token", value: Constants.finApiKey))
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        print("\n\(urlString)\n")
        return URL(string: urlString)
    }
    private func alphaURL (for symbol: String, apiKey: String) -> URL? {
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=\(symbol)&apikey=\(apiKey)"
        print("\n\(urlString)\n")
        return URL(string: urlString)
    }
    private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping(Result<T, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(APIError.invaildURL))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataRecived))
                }
                return
            }
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
