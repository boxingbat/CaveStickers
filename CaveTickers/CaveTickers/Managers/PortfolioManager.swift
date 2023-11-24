//
//  PortfolioManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/20.
//
import Foundation

struct PortfolioManager {
    func calculate(
        timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted,
        initialInvestmentAmount: Double,
        monthlyDollarCostAveragingAmount: Double,
        initialDateOfInvestmentIndex: Int
    ) -> DCAResult {
        let investmentAmount = getInvestmentAmount(
            initialInvestmentAmount: initialInvestmentAmount,
            monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
            initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        let latestSharePrice = getLatestSharePrice(timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
        let numberOfShares = getNumberOfShares(
            timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted,
            initialInvestmentAmount: initialInvestmentAmount,
            monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
            initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        let currentValue = getCurrentValue(
            numberOfShares: numberOfShares,
            latestSharePrice: latestSharePrice)
        let isProfitable = currentValue > investmentAmount
        let gain = ((currentValue - investmentAmount) * 100).rounded() / 100
        let yield = ((gain / investmentAmount) * 10000).rounded() / 100
        let annualReturn = getAnnualReturn(
            currentValue: currentValue,
            investmentAmount: investmentAmount,
            initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        return .init(
            currentValue: currentValue,
            investmentAmount: investmentAmount,
            gain: gain,
            yield: yield,
            annualReturn: annualReturn,
            isProfitable: isProfitable)
    }
    func getInvestmentAmount(
        initialInvestmentAmount: Double,
        monthlyDollarCostAveragingAmount: Double,
        initialDateOfInvestmentIndex: Int
    ) -> Double {
        var totalAmount = Double()
        totalAmount += initialInvestmentAmount
        let dollarCostAveragingAmount = initialDateOfInvestmentIndex.doubleValue * monthlyDollarCostAveragingAmount
        totalAmount += dollarCostAveragingAmount
        return totalAmount
    }
    private func getAnnualReturn(
        currentValue: Double,
        investmentAmount: Double,
        initialDateOfInvestmentIndex: Int
    ) -> Double {
        let rate = currentValue / investmentAmount
        let years = (initialDateOfInvestmentIndex.doubleValue + 1) / 12
        let result = ((pow(rate, (1 / years)) - 1) * 10000).rounded() / 100
        return result
    }
    private func getCurrentValue(numberOfShares: Double, latestSharePrice: Double) -> Double {
        let value = numberOfShares * latestSharePrice
        return (value * 100).rounded() / 100
    }
    private func getLatestSharePrice(timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted) -> Double {
        return timeSeriesMonthlyAdjusted.getMonthInfos().first?.adjustedClose ?? 0
    }
    private func getNumberOfShares(
        timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted,
        initialInvestmentAmount: Double,
        monthlyDollarCostAveragingAmount: Double,
        initialDateOfInvestmentIndex: Int
    ) -> Double {
        var totalShares = Double()
        let initialInvestmentOpenPrice = timeSeriesMonthlyAdjusted.getMonthInfos()[initialDateOfInvestmentIndex].adjustedOpen
        let initialInvestmentShares = initialInvestmentAmount / initialInvestmentOpenPrice
        totalShares += initialInvestmentShares
        timeSeriesMonthlyAdjusted.getMonthInfos().prefix(initialDateOfInvestmentIndex).forEach { monthInfo in
            let dcaInvestmentShares = monthlyDollarCostAveragingAmount / monthInfo.adjustedOpen
            totalShares += dcaInvestmentShares
        }
        return totalShares
    }
}
struct DCAResult {
    let currentValue: Double
    let investmentAmount: Double
    let gain: Double
    let yield: Double
    let annualReturn: Double
    let isProfitable: Bool
}
