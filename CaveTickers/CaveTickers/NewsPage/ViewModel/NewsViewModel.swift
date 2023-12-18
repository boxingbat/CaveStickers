//
//  NewsViewModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/17.
//

import Foundation

class NewsViewModel {
    var news = Observable<[NewsModel]>([])

    func fetchNews() {
        APIManager.shared.news { [weak self] result in
            switch result {
            case .success(let news):
                DispatchQueue.main.async {
                    self?.news.value = news
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
