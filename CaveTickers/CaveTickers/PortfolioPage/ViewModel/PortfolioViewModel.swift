//
//  PortfolioViewModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/18.
//

import Foundation
import Combine

class PortfolioViewModel {
    @Published var savedPortfolio: [SavedPortfolio] = []
    @Published var calculatedResult: [DCAResult] = []
    @Published var pieChartViewModel = PieChartViewModel()

    private var portfolioManager = PortfolioManager()
    private var subscribers = Set<AnyCancellable>()
    let dataLoadedPublisher = PassthroughSubject<Void, Never>()
    var isDataLoaded: Bool {
        return !savedPortfolio.isEmpty && !calculatedResult.isEmpty
    }
    func loadPortfolio() {
        let savedStocks = PersistenceManager.shared.loadPortfolio()
        savedPortfolio = savedStocks

        var tempResults: [String: DCAResult] = [:]
        let group = DispatchGroup()

        for portfolio in savedPortfolio {
            group.enter()
            getHistoricData(symbol: portfolio.symbol) { result in
                if let result = result {
                    tempResults[portfolio.symbol] = result
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.calculatedResult = self.savedPortfolio.compactMap { tempResults[$0.symbol] }
            self.updatePieChart()
            self.dataLoadedPublisher.send(())
        }
    }

    private func getHistoricData(symbol: String, completion: @escaping (DCAResult?) -> Void) {
        APIManager.shared.monthlyAdjusted(for: symbol, keyNumber: Int.random(in: 0...10)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let portfolioItem = self.savedPortfolio.first(where: { $0.symbol == symbol }) {
                        let result = self.portfolioManager.calculate(
                            monthlyAdjusted: response,
                            initialInvestment: portfolioItem.initialInput,
                            monthlyCost: portfolioItem.monthlyInpuy,
                            initialDateOfInvestmentIndex: portfolioItem.timeline
                        )
                        completion(result)
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
        }
    }
    func updatePieChart() {
        let portfolioItems = savedPortfolio.enumerated().compactMap { index, savedItem -> PortfolioItem? in
            guard index < calculatedResult.count else { return nil }
            return PortfolioItem(symbol: savedItem.symbol, dcaResult: calculatedResult[index])
        }
        pieChartViewModel.updateChart(with: portfolioItems)
    }
}
