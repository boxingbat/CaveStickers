//
//  CoinDetailManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/1.
//

import Foundation
import Combine
import SwiftUI

class CoinDetailManager {
    @Published var coinDetails: CoinDetailModel?
    var coinDetailSubscription: AnyCancellable?
    let coin: CoinModel

    init(coin: CoinModel) {
        self.coin = coin
        getCoinDetails()
    }

    func getCoinDetails() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false")
        else { return }
        coinDetailSubscription = NetworkingManager.download(url: url)
            .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion) { [weak self] returnedCoinDetails in
                self?.coinDetails = returnedCoinDetails
                self?.coinDetailSubscription?.cancel()
            }
    }
}
