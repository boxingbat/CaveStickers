//
//  NFTDetailModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import Foundation

// MARK: - NFTAssetStatsModel
struct NFTAssetStatsModel: Codable {
    let stats: Stats?
    let lastSale: LastSale?

    enum CodingKeys: String, CodingKey {
        case stats
        case lastSale = "last_sale"
    }
}

// MARK: - Stats
struct Stats: Codable {
    let oneDayAveragePrice: Int?
    let floorPrice: Double?

    enum CodingKeys: String, CodingKey {
        case oneDayAveragePrice = "one_day_average_price"
        case floorPrice = "floor_price"
    }
}

// MARK: - Last Sale
struct LastSale: Codable {
    let totalPrice: String?

    enum CodingKeys: String, CodingKey {
        case totalPrice = "total_price"
    }
}
