//
//  PortfolioData.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/20.
//

import Foundation

struct UserInput {
    let symbol: String
    let initialInput: String
    let monthlyInpuy: String
    let timeline: TimeInterval
}

struct PortfolioDetail {
    let symbol: String
    let currentPrice: String
    let investedAmount: String
    let currentAmount: String
    let gain: String
    let gainPersentage: String
    let annualRevenue: String
}

struct Portfolio {
    let stoclSymbol: String
    let singleStocl: [PortfolioDetail]
}

struct CalculationResult {
    var currentValue: Double
        var investmentAmount: Double
        var gain: Double
        var yield: Double
        var annualReturn: Double
        var isProfitable: Bool
}

struct SavingPortfolio: Codable {
    var symbol: String
    var initialInput: Double
    var monthlyInpuy: Double
    var timeline: Int
}
