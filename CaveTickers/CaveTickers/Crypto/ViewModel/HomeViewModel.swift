//
//  HomeNewModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/29.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []

    private let APIManager = CoinAPIManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        addSubscribers()
        }

    func addSubscribers() {
        APIManager.$allCoins
            .sink { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
    }
}
