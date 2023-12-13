//
//  MarketDataRespone.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/17.
//

import Foundation

struct SingleDayResponse: Codable {
    let open: Double
    let current: Double
    let high: Double
    let low: Double
    let change: Double
    let changePercent: Double
    let previousPrice: Double
//    let timestamps: [TimeInterval]

    enum CodingKeys: String, CodingKey {
        case open = "o"
        case current = "c"
        case low = "l"
        case high = "h"
        case change = "d"
        case changePercent = "dp"
        case previousPrice = "pc"
//        case timestamps = "t"
    }
}

struct MarketDataRespone: Codable {
    let open: [Double]
    let close: [Double]
    let high: [Double]
    let low: [Double]
    let status: String
    let timestamps: [TimeInterval]

    enum CodingKeys: String, CodingKey {
        case open = "o"
        case close = "c"
        case low = "l"
        case high = "h"
        case status = "s"
        case timestamps = "t"
    }

    var candleSticks: [CandleStick] {
        var result: [CandleStick] = []

        for index in 0..<open.count {
            result.append(
                .init(
                    date: Date(timeIntervalSince1970: timestamps[index]),
                    high: high[index],
                    low: low[index],
                    open: open[index],
                    close: close[index]
                )
            )
        }

        let sortedData = result.sorted { $0.date > $1.date }
        return sortedData
    }
}

struct CompanyInfoResponse: Codable {
    let marketCapitalization: Double?
    let name: String?
    let shareOutstanding: Double?
    let ticker: String?
    let weburl: String?
    let logo: String?
    let finnhubIndustry: String?
}

struct CandleStick {
    let date: Date
    let high: Double
    let low: Double
    let open: Double
    let close: Double
}
