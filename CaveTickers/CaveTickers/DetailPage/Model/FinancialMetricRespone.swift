//
//  FinancialMetricRespone.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/18.
//

import Foundation

/// Metrics response from API
struct FinancialMetricsResponse: Codable {
    let metric: Metrics
}
struct Asset {
    let searchResult: SearchResult
    let timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted
}

/// Financial metrics
struct Metrics: Codable {
    let tenDayAverageTradingVolume: Float
    let annualWeekHigh: Double
    let annualWeekLow: Double
    let annualWeekLowDate: String
    let annualWeekPriceReturnDaily: Float
    let beta: Float

    enum CodingKeys: String, CodingKey {
        case tenDayAverageTradingVolume = "10DayAverageTradingVolume"
        case annualWeekHigh = "52WeekHigh"
        case annualWeekLow = "52WeekLow"
        case annualWeekLowDate = "52WeekLowDate"
        case annualWeekPriceReturnDaily = "52WeekPriceReturnDaily"
        case beta = "beta"
    }
}

struct MonthInfo {
    let date: Date
    let adjustedOpen: Double
    let adjustedClose: Double
}

struct TimeSeriesMonthlyAdjusted: Codable {
    let meta: Meta
    let timeSeries: [String: OHLC]
    enum CodingKeys: String, CodingKey {
        case meta = "Meta Data"
        case timeSeries = "Monthly Adjusted Time Series"
    }

    func getMonthInfos() -> [MonthInfo] {
        var monthInfos: [MonthInfo] = []
        let sortedTimeSeries = timeSeries.sorted(by: { $0.key > $1.key })
        for (dateString, ohlc) in sortedTimeSeries {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = dateFormatter.date(from: dateString),
                let adjustedOpen = getAdjustedOpen(ohlc: ohlc),
                let adjustedClose = ohlc.adjustedClose.toDouble() else { return [] }
            let monthInfo = MonthInfo(date: date, adjustedOpen: adjustedOpen, adjustedClose: adjustedClose)
            monthInfos.append(monthInfo)
        }
        return monthInfos
    }

    private func getAdjustedOpen(ohlc: OHLC) -> Double? {
        guard let open = ohlc.open.toDouble(),
            let adjustedClose = ohlc.adjustedClose.toDouble(),
            let close = ohlc.close.toDouble() else { return nil }
        return open * adjustedClose / close
    }
}

struct Meta: Codable {
    let symbol: String
    enum CodingKeys: String, CodingKey {
        case symbol = "2. Symbol"
    }
}

struct OHLC: Codable {
    let open: String
    let close: String
    let adjustedClose: String
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case close = "4. close"
        case adjustedClose = "5. adjusted close"
    }
}
