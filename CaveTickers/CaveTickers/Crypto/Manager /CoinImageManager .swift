//
//  CoinImageManager .swift
//  CaveTickers
//
//  Created by 1 on 2023/11/29.
//

import Foundation
import SwiftUI
import Combine

class CoinImageManager {
    @Published var image: UIImage?
    private var imageSubscription: AnyCancellable?
    private let coin: CoinModel

    init(coin: CoinModel) {
        self.coin = coin
        getCoinImage()
    }
    private func getCoinImage () {
        guard let url = URL(string: coin.image) else { return }
        imageSubscription = NetworkingManager.download(url: url)
            .tryMap({ (data) -> UIImage? in
                return UIImage(data: data)
            })
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self](returnedImage) in
                self?.image = returnedImage
                self?.imageSubscription?.cancel()
            })
    }
}
