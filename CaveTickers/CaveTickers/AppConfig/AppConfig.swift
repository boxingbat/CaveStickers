//
//  AppConfig.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI
import Foundation

/// Generic configurations for the app
class AppConfig {

    /// This is the AdMob Interstitial ad id
    /// Test App ID: ca-app-pub-3940256099942544~1458002511
//    static let adMobAdId: String = "ca-app-pub-3940256099942544/4411468910"
//    static let adMobFrequency: Int = 3 /// every 3 nft objects seen

    // MARK: - OpenSea APIs
    static let hostName: String = "https://api.opensea.io/api/v1"
    static let assetsAPI: String = "\(hostName)/assets"
    static let assetStatsAPI: String = "\(hostName)/asset"
    static let openSeaAPIDocs: String = "https://docs.opensea.io"

    static let apiKey: String = "ece7871fb832449a9fc9e78d8584da03"

    /// Show/Hide "More Details" button on NFT Details screen
    static let hideMoreDetailsButton: Bool = true

    // MARK: - Widget Configurations
    static let showDebugLogs: Bool = false
    static let widgetDeeplinkURI: String = "widget-deeplink://"
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
        let collectionType = collection != nil ? "&collection=\(collection!.rawValue)" : ""
        let urlString = AppConfig.assetsAPI + "?order_by=\(filter.rawValue)" + collectionType + "&order_direction=\(order.rawValue)&offset=\(offset)&limit=\(limit)"
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

// MARK: - Navigation Tab Bar
enum CustomTabBarItem: String, CaseIterable, Identifiable {
    case home = "house", favorite = "heart", collection = "square.grid.2x2"

    var headerTitle: String {
        switch self {
        case .home:
            return "NFT Marketplace"
        case .favorite:
            return "Favorite NFTs"
        case .collection:
            return "Collections"
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
