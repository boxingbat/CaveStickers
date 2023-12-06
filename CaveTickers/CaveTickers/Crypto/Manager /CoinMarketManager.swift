//
//  CoinMarketManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/30.
//

import Foundation
import Combine

class CoinMarketManager {
    @Published var marketData: MarketDataModel?
    var marketDataSubscription: AnyCancellable?

    init() {
        getData()
    }

    func getData() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global")
        else { return }

        marketDataSubscription = NetworkingManager.download(url: url)
            .decode(type: GlobalData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion) { [weak self] returnedGlobalData in
                self?.marketData = returnedGlobalData.data
                self?.marketDataSubscription?.cancel()
            }
    }
}
