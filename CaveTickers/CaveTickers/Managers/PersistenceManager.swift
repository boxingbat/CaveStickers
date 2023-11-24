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

    private enum Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchListKey = "watchlist"
        static let portolioKey = "Portfolio"
        static let savingStockKey = "savingStock"
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
    public func watchlistContains(symbol: String) -> Bool {
        return watchlist.contains(symbol)
    }
    public func addToWatchList(symbol: String, companyName: String) {
        var current = watchlist
        if !current.contains(symbol) {
            current.append(symbol)
            userDefaults.set(current, forKey: Constants.watchListKey)
            userDefaults.set(companyName, forKey: symbol)
            NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
            if let watchlist = UserDefaults.standard.array(forKey: "watchlist") {
                print("watchlist = \(watchlist)")
            }
        }
    }
    public func removeFromWatchList(symbol: String) {
        var newList: [String] = []

        userDefaults.set(nil, forKey: symbol)
        for item in watchlist where item != symbol {
            newList.append(item)
        }
        userDefaults.set(newList, forKey: Constants.watchListKey)
        print("remove\(symbol)")
        if let watchlist = UserDefaults.standard.array(forKey: "watchlist") {
            print("watchlist = \(watchlist)")
        }
    }

    public func addPortfolio(savingStock: SavingPortfolio) {
        var savingStocks = loadPortfolio()
        savingStocks.append(savingStock)
        save(savingStocks: savingStocks)
    }
    private func save(savingStocks: [SavingPortfolio]) {
        do {
            let data = try JSONEncoder().encode(savingStocks)
            userDefaults.set(data, forKey: Constants.savingStockKey)
            print("set\(data)")
        } catch {
            print("Failed to encode SavingStock array: \(error)")
        }
    }
    public func loadPortfolio() -> [SavingPortfolio] {
        guard let data = userDefaults.data(forKey: Constants.savingStockKey) else {
            return []
        }

        do {
            let result = try JSONDecoder().decode([SavingPortfolio].self, from: data)
            print(result)
            return result
        } catch {
            print("Failed to decode SavingStock array: \(error)")
            return []
        }
    }
    public func deletePortfolio(savingStock: SavingPortfolio) {
        var savingStocks = loadPortfolio()
        savingStocks.removeAll { $0.symbol == savingStock.symbol }
        save(savingStocks: savingStocks)
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
            "TSLA": "Tesla Inc"
        ]
        let symbols = Array(map.keys)
        userDefaults.set(symbols, forKey: Constants.watchListKey)

        for (symbol, name)in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
}
