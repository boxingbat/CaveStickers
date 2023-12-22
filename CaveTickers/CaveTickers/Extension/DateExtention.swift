//
//  DateExtention.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/1.
//

import Foundation
import XCAStocksAPI


extension Date {
    // "2021-03-13T20:49:26.606Z"
    init(coinGeckoString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: coinGeckoString) ?? Date()
        self.init(timeInterval: 0, since: date)
    }

    private var shortFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }

    func asShortDateString() -> String {
        return shortFormatter.string(from: self)
    }
    var MMYYFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }

    func dateComponents(timeZone: TimeZone, rangeType: ChartRange, calendar: Calendar = .current) -> DateComponents {
        let current = calendar.dateComponents(in: timeZone, from: self)

        var date = DateComponents(timeZone: timeZone, year: current.year, month: current.month)

        if rangeType == .oneMonth || rangeType == .oneWeek || rangeType == .oneDay {
            date.day = current.day
        }

        if rangeType == .oneDay {
            date.hour = current.hour
        }

        return date
    }
    func dateAt(hours: Int, minutes: Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        var dateComponents = calendar.components(
            [
                NSCalendar.Unit.year,
                NSCalendar.Unit.month,
                NSCalendar.Unit.day
            ],
            from: self
        )
        dateComponents.hour = hours
        dateComponents.minute = minutes
        let newDate = calendar.date(from: dateComponents)!
        return newDate
    }
    func isUSMarketOpen() -> Bool {
        let marketOpen = self.dateAt(hours: 9, minutes: 30)
        let marketClose = self.dateAt(hours: 16, minutes: 0)
        return self >= marketOpen && self < marketClose
    }
}
