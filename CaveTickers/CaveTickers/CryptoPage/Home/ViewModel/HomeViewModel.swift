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
    @Published var isLoading = false

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
            .map { text, startingsoins -> [CoinModel] in
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
        coinMarketManager.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] returnstate in
                self?.statistics = returnstate
            }
            .store(in: &cancellables)

        // update Portfolio Data
        $allCoins
            .combineLatest(portfolioDataManager.$savedEntities)
            .map { coinModels, portfolioEntities -> [CoinModel] in
                coinModels
                    .compactMap { coin -> CoinModel? in
                        guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) else {
                            return nil
                        }
                        return coin .updateHoldings(amount: entity.amount)
                    }
            }
            .sink { [weak self] returnCoins in
                self?.portfolioCoins = returnCoins
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataManager.updatedPortfolio(coin: coin, amount: amount)
    }

    func reloadData() {
        isLoading = true
        coinAPIManager.getCoins()
        coinMarketManager.getData()
    }
    func mapGlobalMarketData(marketDataModel: MarketDataModel?, portfoliiCoins: [CoinModel]) -> [StatisticModel] {
        var stats: [StatisticModel] = []
        guard let data = marketDataModel else {
            return stats
        }
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = StatisticModel(title: "24H Volume", value: data.volume)
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)

        let portfolioValue =
            portfoliiCoins
            .map { $0.currentHoldingsValue }
            .reduce(0, +)

        let previousValue =
            portfolioCoins
            .map { coin -> Double in
                let currentValue = coin.currentHoldingsValue
                let percentChange = coin.priceChangePercentage24H ?? 0 / 100
                let previousValue = currentValue / (1 + percentChange)
                return previousValue
            }
            .reduce(0, +)

        let percentageChange = ((portfolioValue - previousValue) / previousValue)

        let portfolio = StatisticModel(
            title: "Portfolio Value",
            value: portfolioValue.asCurrencyWith2Decimals(),
            percentageChange: percentageChange
        )

        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            portfolio
        ])
        return stats
    }
}
