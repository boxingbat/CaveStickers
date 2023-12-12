//
//  AppConfig.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI
import Foundation


enum AppConfig {
    // MARK: - OpenSea APIs
    static let hostName: String = "https://api.opensea.io/api/v1"
    static let assetsAPI: String = "\(hostName)/assets"
    static let assetStatsAPI: String = "\(hostName)/asset"
    static let openSeaAPIDocs: String = "https://docs.opensea.io"

    static let apiKey: String = "303f79c1e00542acb9de4413057e9be6"

    /// Show/Hide "More Details" button on NFT Details screen
    static let hideMoreDetailsButton = true
    // MARK: - Widget Configurations
    static let showDebugLogs = false
    static let widgetDeeplinkURI = "widget-deeplink://"
}

// MARK: - API Request Builder
struct AssetsRequestParameters {
    var filter: FilterType
    var collection: NFTCollection?
    var order: OrderType = .descending
    var offset: Int = 0
    var limit: Int = 20

    enum FilterType: String {
        case new = "pk", lastSold = "sale_date", topSeller = "sale_count"
    }

    enum OrderType: String {
        case ascending = "asc", descending = "desc"
    }

    var requestURL: URL? {
        var collectionType = ""
        if let collectionValue = collection?.rawValue {
            collectionType = "&collection=\(collectionValue)"
        }
        let urlString = AppConfig.assetsAPI + "?order_by=\(filter.rawValue)" + collectionType + "&order_direction=\(order.rawValue)&offset=\(offset)&limit=\(limit)"
        print(urlString)
        return URL(string: urlString)
    }
}

struct AssetStatsRequestParameters {
    let address: String
    let token: String

    var requestURL: URL? {
        let urlString = AppConfig.assetStatsAPI + "/" + address + "/" + token
        return URL(string: urlString)
    }
}
struct OwnerAssetsRequestParameters {
    let ownerAddress: String
    var order: OrderType = .descending
    var limit: Int = 20
    var includeOrders = false

    enum OrderType: String {
        case ascending = "asc", descending = "desc"
    }

    var requestURL: URL? {
        let urlString = AppConfig.assetsAPI + "?owner=\(ownerAddress)&order_direction=\(order.rawValue)&limit=\(limit)&include_orders=\(includeOrders)"
        return URL(string: urlString)
    }
}

// MARK: - Navigation Tab Bar
enum CustomTabBarItem: String, CaseIterable, Identifiable {
    case home = "chart.bar.doc.horizontal", favorite = "heart", collection = "books.vertical"

    var headerTitle: String {
        switch self {
        case .home:
            return "Latest NFT"
        case .favorite:
            return "Favorite"
        case .collection:
            return "Gallery"
        }
    }

    var id: Int { hashValue }
}

// MARK: - Collections
enum NFTCollection: String, CaseIterable, Identifiable {
    case blockart
    case cryptocrystal
    case avidLines = "avid-lines"
    case pixelfoxes
    case pixeldoges
    case lostpoets
    case superrare
    case hashmasks
    var id: Int { hashValue }
}
