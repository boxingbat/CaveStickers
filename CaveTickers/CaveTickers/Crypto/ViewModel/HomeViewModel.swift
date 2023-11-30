//
//  HomeNewModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/29.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var statistics: [StatisticModel] = []
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []

    @Published var searchText: String = ""

    private let coinAPIManager = CoinAPIManager()
    private let coinMarketManager = CoinMarketManager()
    private let portfolioDataManager = PortfolioDataManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        addSubscribers()
    }

    func addSubscribers() {
        // updated all coins
        $searchText
            .combineLatest(coinAPIManager.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map { (text, startingsoins) -> [CoinModel] in
                guard !text.isEmpty else {
                    return startingsoins
                }
                let lowercasedText = text.lowercased()
                return startingsoins.filter { coin -> Bool in
                    return coin.name.lowercased().contains(lowercasedText) ||
                    coin.symbol.lowercased().contains(lowercasedText) ||
                    coin.id.lowercased().contains(lowercasedText)
                }
            }
            .sink { [weak self] resturnedCoins in
                self?.allCoins = resturnedCoins
            }
            .store(in: &cancellables)
// update market Data
        coinMarketManager.$marketData
            .map { (marketDataModel) -> [StatisticModel] in
                var stats: [StatisticModel] = []

                guard let data = marketDataModel else {
                    return stats
                }
                let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
                let volume = StatisticModel(title: "24H Volume", value: data.volume)
                let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
                let portfolio = StatisticModel(title: "Portfolio Value", value: "0.00", percentageChange: 0)

                stats.append(contentsOf: [
                    marketCap,
                    volume,
                    btcDominance,
                    portfolio
                ])
                return stats
            }
            .sink{ [weak self] (returnstate) in
                self?.statistics = returnstate
            }
            .store(in: &cancellables)

        // update Portfolio Data
        $allCoins
            .combineLatest(portfolioDataManager.$savedEntities)
            .map { (coinModels, portfolioEntities) -> [CoinModel] in
                coinModels
                    .compactMap { (coin) -> CoinModel? in
                        guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id}) else {
                            return nil
                        }
                        return coin .updateHoldings(amount: entity.amount)
                    }
            }
            .sink { [weak self](returnCoins) in
                self?.portfolioCoins = returnCoins
            }
            .store(in: &cancellables)

    }

    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataManager.updatedPortfolio(coin: coin, amount: amount)
    }
}
