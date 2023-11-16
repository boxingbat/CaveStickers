//
//  ViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import UIKit

class WatchListViewController: UIViewController {
    

    private var searchTimer: Timer?
    ///Model
    private var watchListMap:[String: [String]] = [:]
    ///ViewModel
    private var viewModels: [String: [String]] = [:]
    private var tableView : UITableView = {
        let tableView = UITableView()

        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchController()
        setupTableView()
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
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func setupWatchListData() {
        let symbols = PersistenceManager.shared.watchlist
        for symbol in symbols {
            watchListMap[symbol] = ["some String"]
        }
        tableView.reloadData()
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
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let vc = DetailViewController()
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true)
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchListMap.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Open Detail
    }
}
