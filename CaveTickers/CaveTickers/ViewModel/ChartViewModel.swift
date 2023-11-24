//
//  ChartViewModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//

import Foundation
import SwiftUI
import XCAStocksAPI

@MainActor
class ChartViewModel: ObservableObject {

    @Published var fetchphase = FetchPhase<ChartViewData>.initial
    var chart: ChartViewData? { fetchphase.value }

    let ticker: Ticker
    let apiService: StocksAPI
@AppStorage("selectedRange")
    private var _range = ChartRange.oneDay.rawValue

    @Published var selectedRange = ChartRange.oneDay {
        didSet {
            _range = selectedRange.rawValue
        }
    }

    init(ticker: Ticker, apiService: StocksAPI = XCAStocksAPI()) {
        self.ticker = ticker
        self.apiService = apiService
        self.selectedRange = ChartRange(rawValue: _range) ?? .oneDay
    }

    func fetchData() async {
        do {
            fetchphase = .fetching
            let rangeType = self.selectedRange
            let chartData = try await apiService.fetchChartData(tickerSymbol: ticker.symbol, range: rangeType)

            guard rangeType == self.selectedRange else { return }
            if let chartData {
                fetchphase = .success(transformChartViewData(chartData))
            } else {
                fetchphase = .empty
            }
        } catch {
            fetchphase = .failure(error)
        }
    }

    func transformChartViewData(_ data: ChartData) -> ChartViewData {
        let items = data.indicators.map { ChartViewItem(timestamp: $0.timestamp, value: $0.close) }
            return ChartViewData(
                items: items,
                lineColor: getLineColor(data: data)
            )

        }

    func getLineColor(data: ChartData) -> Color {
        if let last = data.indicators.last?.close {
            if selectedRange == .oneDay, let prevClose = data.meta.previousClose {
                return last >= prevClose ? .green : .red
            }else if let first = data.indicators.first?.close {
                return last >= first ? .green : .red
            }
        }
        return .blue
    }
}
