//
//  TestingBackViewModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/18.
//

import Foundation
import Combine

class TestingBackViewModel {
    @Published var newSavingStock: SavedPortfolio
    @Published var monthlyAdjusted: TimeSeriesMonthlyAdjusted?
    @Published var computedResult: DCAResult?
    @Published var resultSymbol: String?

    private var subscribers = Set<AnyCancellable>()
    private let portfolioManager = PortfolioManager()

    @Published var initialSymbol: String?
    @Published var initialDateOfInvestmentIndex: Int?
    @Published var initialInvestmentAmount: Int?
    @Published var monthlyDollarCostAveragingAmount: Int?

    // callback
    var onFetchCompleted: ((Result<TimeSeriesMonthlyAdjusted, Error>) -> Void)?
    var onDateSelected: ((Int) -> Void)?

    init() {
        newSavingStock = SavedPortfolio(
            symbol: "",
            initialInput: 0,
            monthlyInpuy: 0,
            timeline: 0)
            initialSymbol = nil
            initialDateOfInvestmentIndex = nil
            initialInvestmentAmount = nil
            monthlyDollarCostAveragingAmount = nil
            setupCombineSubscriptions()
        }

    private func setupCombineSubscriptions() {
        Publishers.CombineLatest4(
            $initialSymbol,
            $initialInvestmentAmount,
            $monthlyDollarCostAveragingAmount,
            $initialDateOfInvestmentIndex
        )
        .sink { [weak self] symbol, investmentAmount, monthlyAmount, dateIndex in
            self?.calculateAndDisplayResult(
                symbol: symbol,
                investmentAmount: investmentAmount,
                monthlyAmount: monthlyAmount,
                dateIndex: dateIndex
            )
        }
        .store(in: &subscribers)
    }

    func calculateAndDisplayResult(symbol: String?, investmentAmount: Int?, monthlyAmount: Int?, dateIndex: Int?) {
        guard let symbol = symbol,
            let investmentAmount = investmentAmount,
            let monthlyAmount = monthlyAmount,
            let dateIndex = dateIndex,
            let monthlyAdjusted = monthlyAdjusted else {
        print("Error: Required data is missing")
        return
    }

        let result = portfolioManager.calculate(
            monthlyAdjusted: monthlyAdjusted,
            initialInvestment: Double(investmentAmount),
            monthlyCost: Double(monthlyAmount),
            initialDateOfInvestmentIndex: dateIndex
        )

        newSavingStock = SavedPortfolio(symbol: symbol, initialInput: Double(investmentAmount), monthlyInpuy: Double(monthlyAmount), timeline: dateIndex)
        computedResult = result
        resultSymbol = symbol
    }

    private func fetchMonthlyAdjustedData(for symbol: String) {
        //        self.showLoadingView()
        APIManager.shared.monthlyAdjusted(for: symbol, keyNumber: Int.random(in: 11...17)) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleAPIResult(result)
            }
        }
    }
    private func handleAPIResult(_ result: Result<TimeSeriesMonthlyAdjusted, Error>) {
        switch result {
        case .success(let response):
            self.monthlyAdjusted = response
            onDateSelected = { [weak self] selectedIndex in
                guard let self = self,
                    let symbol = self.initialSymbol,
                    let investmentAmount = self.initialInvestmentAmount,
                    let monthlyAmount = self.monthlyDollarCostAveragingAmount else {
                print("Error: Required data for calculation is missing")
                return }
                self.calculateAndDisplayResult(
                    symbol: symbol,
                    investmentAmount: investmentAmount,
                    monthlyAmount: monthlyAmount,
                    dateIndex: selectedIndex
                )
            }
        case .failure(let error):
            print(error)
        }
    }
}
