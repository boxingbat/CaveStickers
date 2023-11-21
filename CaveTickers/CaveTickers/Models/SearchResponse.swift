//
//  SearchResponse.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/16.
//

import Foundation

struct SearchResponse: Codable {
    let count: Int
    let result: [SearchResult]
}

struct SearchResult: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
