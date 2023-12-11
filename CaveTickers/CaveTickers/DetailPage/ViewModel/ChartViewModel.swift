//
//  ChartViewModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//

import Foundation
import SwiftUI
import XCAStocksAPI
import Charts

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

    @Published var selectedX: (any Plottable)?

    var selectedXRuleMark: (value: Int, text: String)? {
        guard let selectedX = selectedX as? Int,
            let chart
        else { return nil }
        return (selectedX,
            chart.items[selectedX].value.roundedString
        )
    }

    var foregroundMarkColor: Color {
        (selectedX != nil) ? .cyan : (chart?.lineColor ?? .cyan)
    }

    private let selectedValueDateFormatter = {
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .medium
        return dateFormat
    }()

    private let dateFormatter = DateFormatter()

    var selectedXDateText: String {
        guard let selectedX = selectedX as? Int, let chart else { return "" }
        if selectedRange == .oneDay || selectedRange == .oneWeek {
            selectedValueDateFormatter.timeStyle = .short
        } else {
            selectedValueDateFormatter.timeStyle = .none
        }
        let item = chart.items[selectedX]
        return selectedValueDateFormatter.string(from: item.timestamp)
    }

    var selectedXOpacity: Double {
        selectedX == nil ? 1 : 0
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
        //        let items = data.indicators.map { ChartViewItem(timestamp: $0.timestamp, value: $0.close) }
        let (xAxisChartData, items) = xAxisChartDataAndItems(data)
        let yAxisChartData = yAxisChartData(data)
        return ChartViewData(
            xAxisData: xAxisChartData,
            yAxisData: yAxisChartData,
            items: items,
            lineColor: getLineColor(data: data),
            previousCloseRuleMarkValue: previuesCloseRuleMarkValue(data: data, yAxisData: yAxisChartData)
        )
    }
    func xAxisChartDataAndItems(_ data: ChartData) -> (ChartAxisData, [ChartViewItem]) {
        let timezone = TimeZone(secondsFromGMT: data.meta.gmtOffset) ?? .gmt
        dateFormatter.timeZone = timezone
        selectedValueDateFormatter.timeZone = timezone
        dateFormatter.dateFormat = selectedRange.dateFormat

        var xAxisDateComponents = Set<DateComponents>()
        if let startTimestamp = data.indicators.first?.timestamp {
            if selectedRange == .oneDay {
                xAxisDateComponents = selectedRange.getDateComponents(
                    startDate: startTimestamp,
                    endDate: data.meta.regularTradingPeriodEndDate,
                    timezone: timezone
                )
            } else if let endTimestamp = data.indicators.last?.timestamp {
                xAxisDateComponents = selectedRange.getDateComponents(
                    startDate: startTimestamp,
                    endDate: endTimestamp,
                    timezone: timezone
                )
            }
        }

        var map: [String: String] = [:]
        var axisEnd: Int

        var items: [ChartViewItem] = []

        for (index, value) in data.indicators.enumerated() {
            let dateComponent = value.timestamp.dateComponents(timeZone: timezone, rangeType: selectedRange)
            if xAxisDateComponents.contains(dateComponent) {
                map[String(index)] = dateFormatter.string(from: value.timestamp)
                xAxisDateComponents.remove(dateComponent)
            }

            items.append(ChartViewItem(
                timestamp: value.timestamp,
                value: value.close))
        }
        axisEnd = items.count - 1

        if selectedRange == .oneDay,
        var date = items.last?.timestamp,
        date >= data.meta.regularTradingPeriodStartDate &&
            date < data.meta.regularTradingPeriodEndDate {
            while date < data.meta.regularTradingPeriodEndDate {
                guard let newDate = Calendar.current.date(byAdding: .minute, value: 2, to: date) else { break }
                date = newDate
                let dateComponent = date.dateComponents(timeZone: timezone, rangeType: selectedRange)
                if xAxisDateComponents.contains(dateComponent) {
                    map[String(axisEnd)] = dateFormatter.string(from: date)
                    xAxisDateComponents.remove(dateComponent)
                }
                axisEnd += 1
            }
        }

        let xAxisData = ChartAxisData(
            axisStart: 0,
            axisEnd: Double(max(0, axisEnd)),
            strideBy: 1,
            map: map)

        return (xAxisData, items)
    }

    func yAxisChartData(_ data: ChartData) -> ChartAxisData {
        let closes = data.indicators.map { $0.close }
        var lowest = closes.min() ?? 0
        var highest = closes.max() ?? 0

        if let prevClose = data.meta.previousClose,
        selectedRange == .oneDay {
            if prevClose < lowest {
                lowest = prevClose
            } else if prevClose > highest {
                highest = prevClose
            }
        }

        // 2
        let diff = highest - lowest

        // 3
        let numberOfLines: Double = 4
        let shouldCeilIncrement: Bool
        //        let strideBy: Double

        if diff < (numberOfLines * 2) {
            // 4A
            shouldCeilIncrement = false
            //            strideBy = 0.01
        } else {
            // 4B
            shouldCeilIncrement = true
            lowest = floor(lowest)
            highest = ceil(highest)
            //            strideBy = 1.0
        }
        // 5
        let increment = ((highest - lowest) / (numberOfLines))
        var map: [String: String] = [:]
        map[highest.roundedString] = formatYAxisValueLabel(value: highest, shouldCeilIncrement: shouldCeilIncrement)

        var current = lowest
        (0..<Int(numberOfLines) - 1).forEach { _ in
            current += increment
            map[
                (
                    shouldCeilIncrement ? ceil(current) : current)
                .roundedString] = formatYAxisValueLabel(
                    value: current,
                    shouldCeilIncrement: shouldCeilIncrement
                )
        }
        return ChartAxisData(
            axisStart: lowest + 0.01,
            axisEnd: highest + 0.01,
            strideBy: 0,
            map: [:]
        )
    }

    func previuesCloseRuleMarkValue(data: ChartData, yAxisData: ChartAxisData) -> Double? {
        guard let previousClose = data.meta.previousClose,
            selectedRange == .oneDay else {
            return nil
        }
        return (yAxisData.axisStart <= previousClose && previousClose <= yAxisData.axisEnd) ? previousClose : nil
    }

    private func formatYAxisValueLabel(value: Double, shouldCeilIncrement: Bool) -> String {
        if shouldCeilIncrement {
            return String(Int(ceil(value)))
        } else {
            return Utils.numberFormatter.string(from: NSNumber(value: value)) ?? value.roundedString
        }
    }
    func getLineColor(data: ChartData) -> Color {
        if let last = data.indicators.last?.close {
            if selectedRange == .oneDay, let prevClose = data.meta.previousClose {
                return last >= prevClose ? .green : .red
            } else if let first = data.indicators.first?.close {
                return last >= first ? .green : .red
            }
        }
        return .blue
    }
}