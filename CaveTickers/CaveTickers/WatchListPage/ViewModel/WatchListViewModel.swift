//
//  WatchListViewModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/16.
//

import Foundation
import UIKit

class WatchListViewModel {
    var watchlistArray = Observable<[WatchListModel]>([])
    func fetchWatchlistData() {
        let symbols = PersistenceManager.shared.watchlist
        var singleDayMap: [String: SingleDayResponse] = [:]
        var companyInfo: [String: CompanyInfoResponse] = [:]

        let group = DispatchGroup()

        for symbol in symbols {
            group.enter()
            APIManager.shared.singleDayData(for: symbol) { result in
                defer { group.leave() }
                switch result {
                case .success(let data):
                    singleDayMap[symbol] = data
                case .failure(let error):
                    print(error)
                }
            }

            group.enter()
            APIManager.shared.companyInfo(for: symbol) { result in
                defer { group.leave() }
                switch result {
                case .success(let data):
                    companyInfo[symbol] = data
                case .failure(let error):
                    print(error)
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.createViewModels(singleDayMap: singleDayMap, companyInfo: companyInfo)
        }
    }
    private func createViewModels(singleDayMap: [String: SingleDayResponse], companyInfo: [String: CompanyInfoResponse]) {
        self.watchlistArray.value = singleDayMap.compactMap { symbol, singleDayResponse -> WatchListModel? in
            guard let companyInfoResponse = companyInfo[symbol] else { return nil }
            let changeColor: UIColor = singleDayResponse.changePercent < 0 ? UIColor(named: "RedColor") ?? .systemRed : .systemGreen
            return WatchListModel(
                symbol: symbol,
                price: "\(singleDayResponse.current)",
                changeColor: changeColor,
                companyName: companyInfoResponse.name ?? symbol,
                changePercentage: singleDayResponse.changePercent.asPercentString(),
                marketCaptital: companyInfoResponse.marketCapitalization?.formatUsingAbbrevation() ?? "",
                shareOutstanding: companyInfoResponse.shareOutstanding?.formatUsingAbbrevation() ?? ""
            )
        }
    }
}
