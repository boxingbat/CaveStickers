//
//  NewsModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/27.
//

import Foundation

struct NewsStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
