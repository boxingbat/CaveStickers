//
//  PortfolioData.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/20.
//

import Foundation

struct UserInput {
    let symbol: String
    let InitialInput: String
    let MonthlyInpuy: String
    let timeline: TimeInterval
}

struct PortfolioDetail {
    let symbol: String
    let CurrentPrice: String
    let InvestedAmount: String
    let CurrentAmount: String
    let gain: String
    let gainPersentage: String
    let annualRevenue: String
}

struct Portfolio {
    let stoclSymbol: String
    let SingleStocl: [PortfolioDetail]
}