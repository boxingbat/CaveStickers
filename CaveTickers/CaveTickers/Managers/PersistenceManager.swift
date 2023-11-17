//
//  StorageManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/16.
//

import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()

    private let userDefaults: UserDefaults = .standard

    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchListKey = "watchlist"
    }

    private init () {}

    // MARK: - Public

    public var watchlist: [String] {
        if !hasOnBoarded {
            userDefaults.set(true, forKey: Constants.onboardedKey)
            setupDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchListKey) ?? []
    }

    public func addToWatchList() {

    }

    public func removeFromWatchList() {

    }

    // MARK: - Pravite

    private var hasOnBoarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }

    private func setupDefaults () {
        let map: [String: String] = [
            "AAPL": "Apple Inc",
            "GOOG": "Alphabet",
            "AMZN": "Amazon.com Inc",
            "MSFT": "Microsoft Corporation",
            "NVDA": "Nvdia Inc",
            "TSLA": "Tesla Inc"]
        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchListKey)

        for (symbol, name)in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
}
