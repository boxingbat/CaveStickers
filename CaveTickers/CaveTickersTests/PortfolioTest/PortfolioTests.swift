//
//  CaveTickersTests.swift
//  CaveTickersTests
//
//  Created by 1 on 2023/12/25.
//

import XCTest
@testable import CaveTickers

final class PortfolioTests: XCTestCase {
    var portfolioManager = PortfolioManager()

    func testGetInvestmentAmount() {
        checkInvestmentAmount(initialInvestment: 1000.0, monthlyCost: 100.0, investmentIndex: 5, expectedTotal: 1500.0)
        checkInvestmentAmount(initialInvestment: 0.0, monthlyCost: 5000.0, investmentIndex: 5, expectedTotal: 25000.0)
        checkInvestmentAmount(initialInvestment: 10000.0, monthlyCost: 0.0, investmentIndex: 5, expectedTotal: 10000.0)
    }
    private func checkInvestmentAmount(initialInvestment: Double, monthlyCost: Double, investmentIndex: Int, expectedTotal: Double) {
        let result = portfolioManager.getInvestmentAmount(
            initialInvestmentAmount: initialInvestment,
            monthlyDollarCostAveragingAmount: monthlyCost,
            initialDateOfInvestmentIndex: investmentIndex)
        XCTAssertEqual(result, expectedTotal, accuracy: 0.01, "Investment amount calculated incorrectly for initial investment: \(initialInvestment), monthly cost: \(monthlyCost), investment index: \(investmentIndex).")
    }
    func testCalculate() {
        let testParams1 = CalculateTestParameters(initialInvestment: 1000.0, monthlyCost: 100.0, investmentIndex: 1, expectedCurrentValue: 5100, expectedInvestmentAmount: 1100, expectedGain: 4000, expectedYield: 363.636, expectedProfitable: true)
        checkCalculateTest(with: testParams1)

        let testParams2 = CalculateTestParameters(initialInvestment: 2000.0, monthlyCost: 0, investmentIndex: 1, expectedCurrentValue: 10000, expectedInvestmentAmount: 2000, expectedGain: 8000, expectedYield: 400, expectedProfitable: true)
        checkCalculateTest(with: testParams2)

        let testParams3 = CalculateTestParameters(initialInvestment: 0.0, monthlyCost: 1000, investmentIndex: 1, expectedCurrentValue: 1000, expectedInvestmentAmount: 1000, expectedGain: 0, expectedYield: 0, expectedProfitable: false)
        checkCalculateTest(with: testParams3)
    }
    private func checkCalculateTest(with parameters: CalculateTestParameters) {
        let mockMonthlyAdjusted = createMockMonthlyAdjusted()

        let result = portfolioManager.calculate(
            monthlyAdjusted: mockMonthlyAdjusted,
            initialInvestment: parameters.initialInvestment,
            monthlyCost: parameters.monthlyCost,
            initialDateOfInvestmentIndex: parameters.investmentIndex
        )

        XCTAssertEqual(result.currentValue, parameters.expectedCurrentValue, accuracy: 0.01)
        XCTAssertEqual(result.investmentAmount, parameters.expectedInvestmentAmount, accuracy: 0.01)
        XCTAssertEqual(result.gain, parameters.expectedGain, accuracy: 0.01)
        XCTAssertEqual(result.yield, parameters.expectedYield, accuracy: 0.01)
        XCTAssertEqual(result.isProfitable, parameters.expectedProfitable)
    }

    private func createMockMonthlyAdjusted() -> TimeSeriesMonthlyAdjusted {
        let mockOHLC1 = OHLC(open: "1000", close: "1000", adjustedClose: "1000")
        let mockOHLC2 = OHLC(open: "200", close: "200", adjustedClose: "200")
        let mockTimeSeries = [
            "2023-04-30": mockOHLC1,
            "2023-03-31": mockOHLC2
        ]
        let mockMeta = Meta(symbol: "TEST")
        return TimeSeriesMonthlyAdjusted(meta: mockMeta, timeSeries: mockTimeSeries)
    }
}
