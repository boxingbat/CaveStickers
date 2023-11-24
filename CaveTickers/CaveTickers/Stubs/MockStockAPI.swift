//
//  MockStockAPI.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//


import Foundation
import XCAStocksAPI

#if DEBUG
struct MockStocksAPI: StocksAPI {

    var stubbedSearchTickersCallback: ( () async throws -> [Ticker])!
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [Ticker] {
        try await stubbedSearchTickersCallback()
    }

    var stubbedFetchQuotesCallback: ( () async throws -> [Quote])!
    func fetchQuotes(symbols: String) async throws -> [Quote] {
        try await stubbedFetchQuotesCallback()
    }

    var stubbedFetchChartDataCallback: ((ChartRange) async throws  -> ChartData?)! = { $0.stubs }
    func fetchChartData(tickerSymbol: String, range: ChartRange) async throws -> ChartData? {
        try await stubbedFetchChartDataCallback(range)
    }

}
#endif
