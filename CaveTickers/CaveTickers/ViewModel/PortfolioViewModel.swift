//
//  PortfolioViewModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/26.
//

import Foundation

struct PortfolioItem {
    let symbol: String
    let dcaResult: DCAResult
}

class PieChartViewModel: ObservableObject {
    @Published var pieChartSegments: [PieChartSegment] = []
    @Published var totalInvestmentAmount: Double = 0
    @Published var totalCurrentValue: Double = 0
    @Published var growthRate: Double = 0

    func updateChart(with portfolioItems: [PortfolioItem]) {
        let totalInvested = portfolioItems.reduce(0) { $0 + $1.dcaResult.investmentAmount }
        let totalCurrent = portfolioItems.reduce(0) { $0 + $1.dcaResult.currentValue }
        let growth = totalCurrent - totalInvested
        let rate = (growth / totalInvested) * 100

        self.totalInvestmentAmount = totalInvested
        self.totalCurrentValue = totalCurrent
        self.growthRate = rate

        let totalValue = portfolioItems.reduce(0) { $0 + $1.dcaResult.currentValue }

        pieChartSegments = portfolioItems.map { item in
            let percentage = (item.dcaResult.currentValue / totalValue) * 100
            return PieChartSegment(symbol: item.symbol, value: item.dcaResult.currentValue, percentage: percentage)
        }
    }
}


struct PieChartSegment {
    let symbol: String
    let value: Double
    let percentage: Double
}


