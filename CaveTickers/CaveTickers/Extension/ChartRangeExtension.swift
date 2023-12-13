//
//  ChartRange.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//

import Foundation
import SwiftUI
import XCAStocksAPI

extension ChartRange: Identifiable {
    public var id: Self { self }

    var title: String {
        switch self {
        case .oneDay: return "1D"
        case .oneWeek: return "1W"
        case .oneMonth: return "1M"
        case .threeMonth: return "3M"
        case .sixMonth: return "6M"
        case .oneYear: return "1Y"
        case .twoYear: return "2Y"
        case .fiveYear: return "5Y"
        case .tenYear: return "10Y"
        case .ytd: return "YTD"
        case .max: return "ALL"
        }
    }

    var dateFormat: String {
        switch self {
        case .oneDay: return "H"
        case .oneWeek, .oneMonth: return "d"
        case .threeMonth, .sixMonth, .ytd: return "MMM"
        case .oneYear, .twoYear: return "MMMM"
        case .fiveYear, .tenYear, .max: return "yyyy"
        }
    }

    func getDateComponents(startDate: Date, endDate: Date, timezone: TimeZone) -> Set<DateComponents> {
        let component: Calendar.Component
        let value: Int
        (component, value) = getComponentAndValue()

        var set  = Set<DateComponents>()
        var date = startDate
        if self != .oneDay {
            set.insert(startDate.dateComponents(timeZone: timezone, rangeType: self))
        }
        while date <= endDate {
            guard let newDate = Calendar.current.date(byAdding: component, value: value, to: date) else { break }
            date = newDate
            set.insert(newDate.dateComponents(timeZone: timezone, rangeType: self))
        }
        return set
    }
    private func getComponentAndValue() -> (Calendar.Component, Int) {
        switch self {
        case .oneDay:
            return (.hour, 1)
        case .oneWeek:
            return (.day, 1)
        case .oneMonth:
            return (.weekOfYear, 1)
        case .threeMonth, .sixMonth:
            return (.month, 1)
        case .ytd:
            return (.month, 2)
        case .oneYear:
            return (.month, 4)
        case .twoYear:
            return (.month, 6)
        case .fiveYear, .tenYear:
            return (.year, 2)
        case .max:
            return (.year, 8)
        }
    }
}
