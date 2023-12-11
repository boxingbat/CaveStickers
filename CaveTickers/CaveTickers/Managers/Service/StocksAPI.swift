//
//  StocksAPI.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//

import Foundation
import XCAStocksAPI

protocol StocksAPI {
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [Ticker]
    func fetchQuotes(symbols: String) async throws -> [Quote]
    func fetchChartData(tickerSymbol: String, range: ChartRange) async throws -> ChartData?
}
extension XCAStocksAPI: StocksAPI {}
