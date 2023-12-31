//
//  CoinAPIManager .swift
//  CaveTickers
//
//  Created by 1 on 2023/11/29.
//

import Foundation
import Combine
import SwiftUI

class CoinAPIManager {
    @Published var allCoins: [CoinModel] = []
    var coinSubscription: AnyCancellable?

    init() {
        getCoins()
    }

    func getCoins() {
        guard let url = URL(string:
        "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h")
        else { return }
        coinSubscription = NetworkingManager.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion) { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
                self?.coinSubscription?.cancel()
            }
    }
}
