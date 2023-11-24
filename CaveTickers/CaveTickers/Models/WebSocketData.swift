//
//  WebSocketData.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/22.
//

import Foundation

struct WebsocketStockInfo: Codable {
    var type: String
    var data: [PriceData]
}
struct PriceData: Codable {
    var symbolData: String // symbol
    var priceData: Double // price

    enum CodingKeys: String, CodingKey {
        case priceData = "p"
        case symbolData = "s"
    }
}
