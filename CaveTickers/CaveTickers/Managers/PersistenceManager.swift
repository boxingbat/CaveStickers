//
//  StorageManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/16.
//

import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()

    private let userDefault: UserDefaults = .standard

    private struct Constants {

    }

    private init () {}

    // MARK: - Public

    public var watchlist: [String] {
        return[]
    }

    public func addToWatchList() {

    }

    public func removeFromWatchList() {

    }

    // MARK: - Pravite

    private var hasOnBoarded: Bool {
        return false
    }
}
