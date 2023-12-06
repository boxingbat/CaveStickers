//
//  coinImageViewModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/29.
//

import Foundation
import SwiftUI
import Combine

class CoinImageViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var isloading = false

    private let coin: CoinModel
    private let coinImageManager: CoinImageManager

    // save subscription
    private var cancellables = Set<AnyCancellable>()

    init(coin: CoinModel) {
        self.coin = coin
        self.coinImageManager = CoinImageManager(coin: coin)
        addSubscribers()
        self.isloading = true
    }

    private func addSubscribers() {
        coinImageManager.$image
            .sink { [weak self] _ in
                self?.isloading = false
            } receiveValue: { [weak self] returnImage in
                self?.image = returnImage
            }
            .store(in: &cancellables)
    }
}
