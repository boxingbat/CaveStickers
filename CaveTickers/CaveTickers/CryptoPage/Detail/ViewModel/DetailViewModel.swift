//
//  DetailViewModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/1.
//

import Foundation
import Combine
import UIKit
import SwiftUI

class DetailViewModel: ObservableObject {
    enum PriceChange {
        case increased
        case decreased
        case noChange
    }

    @Published var latestPrice: String = ""
    @Published var overviewStatistics: [StatisticModel] = []
    @Published var addtionalStatistics: [StatisticModel] = []
    @Published var flashColor: Color = .clear
    @Published var priceChange: PriceChange = .noChange


    @Published var coin: CoinModel
    private let coinDetailManager: CoinDetailManager
    @Published var portfolioDataManager: PortfolioDataManager
    private var cancellables = Set<AnyCancellable>()
    private var webSocketManager = WebSocketManager()

    // Combined initializer
        init(coin: CoinModel) {
            self.coin = coin
            self.coinDetailManager = CoinDetailManager(coin: coin)
            self.portfolioDataManager = PortfolioDataManager()
            addSubscribers()
            setupWebSocketSubscriptions()
        }
    private func setupWebSocketSubscriptions() {
            webSocketManager.latestPriceSubject
                .sink { [weak self] latestPrice in
                    DispatchQueue.main.async {
                        if let oldPrice = Double(self?.latestPrice ?? "0"), let newPrice = Double(latestPrice) {
                            if newPrice > oldPrice {
                                self?.priceChange = .increased
                            } else if newPrice < oldPrice {
                                self?.priceChange = .decreased
                            } else {
                                self?.priceChange = .noChange
                            }
                        }
                        self?.latestPrice = latestPrice
                    }
                }
                .store(in: &cancellables)
        }

//    init(coin: CoinModel) {
//        self.coin = coin
//        self.coinDetailManager = CoinDetailManager(coin: coin)
//        self.portfolioDataManager = PortfolioDataManager()
//        self.addSubscribers()
//    }

    func ifCoinInPortfolio(coinID: String) -> Bool {
        let coinExists = portfolioDataManager.isCoinInPortfolio(coinID: coinID)
        return coinExists
    }

    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataManager.updatedPortfolio(coin: coin, amount: 1)
    }

    func deleteCoin(coin: CoinModel) {
        portfolioDataManager.deleteCoin(coin: coin)
    }
    private func addSubscribers() {
        coinDetailManager.$coinDetails
            .combineLatest($coin)
            .map(mapDataToStatistics)
            .sink { [weak self] returnArrays in
                self?.overviewStatistics = returnArrays.overview
                self?.addtionalStatistics = returnArrays.addtional
            }
            .store(in: &cancellables)
    }
    func connectWebSocket(withSymbol symbol: String) {
        let formattedSymbol = "BINANCE:\(symbol.uppercased())USDT"
        webSocketManager.connect(withSymbol: formattedSymbol)
        webSocketManager.send(symbol: formattedSymbol)
    }

    func disconnectWebSocket() {
        webSocketManager.close()
    }

    deinit {
        webSocketManager.close()
    }

    private func mapDataToStatistics(coinDetailModel: CoinDetailModel?, coinModel: CoinModel) -> (overview: [StatisticModel], addtional: [StatisticModel]) {
        let price = coinModel.currentPrice.asCurrencyWith2Decimals()
        let pricePercentChange = coinModel.priceChangePercentage24H
        let priceStat = StatisticModel(title: "Current Price", value: price, percentageChange: pricePercentChange)

        let marketCap = "$" + (coinModel.marketCap?.formattedWithAbbreviations() ?? "")
        let marketPercentChange = coinModel.marketCapChangePercentage24H
        let marketCapStat = StatisticModel(title: "Market Capitalization", value: marketCap, percentageChange: marketPercentChange)

        let rank = "\(coinModel.rank)"
        let rankStat = StatisticModel(title: "Rank", value: rank)

        let volume = "$" + (coinModel.totalVolume?.formattedWithAbbreviations() ?? "")
        let volumeStat = StatisticModel(title: "Volume", value: volume)

        let overviewArray: [StatisticModel] = [
            priceStat, marketCapStat, rankStat, volumeStat
        ]

        // Additional

        let high = coinModel.high24H?.asCurrencyWith6Decimals() ?? "n/a"
        let highStat = StatisticModel(title: "24H High", value: high)

        let low = coinModel.low24H?.asCurrencyWith6Decimals() ?? "n/a"
        let lowStat = StatisticModel(title: "24H Low", value: low)

        let priceChange = coinModel.priceChange24H?.asCurrencyWith6Decimals() ?? "n/a"
        let pricePercemtChange2 = coinModel.priceChangePercentage24H
        let priceChangeStat = StatisticModel(title: "24H Price Change", value: priceChange, percentageChange: pricePercemtChange2)

        let marketCapChange = "$" + (coinModel.marketCapChange24H?.formattedWithAbbreviations() ?? "")
        let marketCapPercentChange2 = coinModel.priceChangePercentage24H
        let marketCapChangeStat = StatisticModel(title: "24h Market Cap Change", value: marketCapChange, percentageChange: marketCapPercentChange2)

        let blockTime = coinDetailModel?.blockTimeInMinutes ?? 0
        let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime)"
        let blockStat = StatisticModel(title: "Block Time", value: blockTimeString)

        let hashing = coinDetailModel?.hashingAlgorithm ?? "n/a"
        let hashingStat = StatisticModel(title: "Hashing Algorithm", value: hashing)

        let additionalArray: [StatisticModel] = [
            highStat, lowStat, priceChangeStat, marketCapChangeStat, blockStat, hashingStat
        ]

        return(overviewArray, additionalArray)
    }
}
