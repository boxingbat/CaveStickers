//
//  ViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import UIKit

class WatchListViewController: UIViewController {

    private var searchTimer: Timer?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchController()
        setupTitleView()
    }

    //MARK: - Private

    private func setupTitleView() {
        let titleView = UIView(frame:  CGRect(
            x: 10,
            y: 0,
            width: view.width,
            height: navigationController?.navigationBar.height ?? 100)
        )

        let label = UILabel(frame: CGRect(
            x: 10,
            y: 0,
            width: titleView.width-20,
            height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 32, weight: .medium)
        titleView.addSubview(label)

        navigationItem.titleView = titleView
    }

    private func setUpSearchController() {
        let resultVC = SearchViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }

}

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsController as? SearchViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        //reset Timer
        searchTimer?.invalidate()

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            APIManager.shared.search(query: query) {result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultsVC.update(with: response.result)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultsVC.update(with: [])
                    }
                    print(error)
                }
            }
        })

    }
}

extension WatchListViewController: SearchTableViewDelegate {
    func searchViewControllerDidSelect(searchResult: SearchResult) {
        // present detail
        print("Did Select: \(searchResult.displaySymbol)")
    }
}
