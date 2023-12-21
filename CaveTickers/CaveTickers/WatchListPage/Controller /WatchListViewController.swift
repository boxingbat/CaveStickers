//
//  ViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import UIKit
import SwiftUI

class WatchListViewController: LoadingViewController {
    // MARK: - Variables
    private var searchTimer: Timer?
    private var watchListMap: [String: [CandleStick]] = [:]
    private var tableView = UITableView()
    private var headerView = TableSectionHeaderView()
    private var observer: NSObjectProtocol?
    private var loadingStateVC: UIHostingController<LoadingStateView>?
    private var fetchedData = false
    private var viewModels: [WatchListModel] = []
    private var viewModel = WatchListViewModel()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Environment Setting
        UILabel.appearance().textColor = UIColor(named: "AccentColor")
        UIButton.appearance().setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "AccentColor") ?? .black]
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.backgroundColor = .systemBackground
        /// Set Up Component
        setUpSearchController()
        setupTableView()
        showLoadingView()
        setupTitleView()
        setupViewModelBinding()
        viewModel.fetchWatchlistData()
        fetchedData = true
        setUpObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if fetchedData {
            viewModel.fetchWatchlistData()
        }
    }
    // MARK: - Private
    private func setupViewModelBinding() {
        viewModel.watchlistArray.bind { [weak self] _ in
            self?.tableView.reloadData()
            self?.hideLoadingView()
        }
    }
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .didAddToWatchList,
            object: nil,
            queue: .main) { [weak self]_ in
                self?.viewModel.fetchWatchlistData()
        }
    }
    private func setupTitleView() {
        let titleView = UIView(frame: CGRect(
            x: 10,
            y: 0,
            width: view.width,
            height: navigationController?.navigationBar.height ?? 100)
        )

        let label = UILabel(frame: CGRect(
            x: 10,
            y: 0,
            width: titleView.width - 20,
            height: titleView.height))
        label.text = "WatchList"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        titleView.addSubview(label)

        navigationItem.titleView = titleView
        navigationItem.titleView?.backgroundColor = .systemBackground
    }
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        tableView.backgroundColor = .systemBackground
    }

    private func setUpSearchController() {
        let resultVC = SearchViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
}
// MARK: - Extension
/// Searching
extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
        let resultsVC = searchController.searchResultsController as? SearchViewController,
        !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        searchTimer?.invalidate()

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
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
        }
    }
}
extension WatchListViewController: SearchTableViewDelegate {
    func searchViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()

        let detailVc = DetailViewController(
            symbol: searchResult.symbol,
            companyName: searchResult.description
        )
        _ = searchResult.symbol
        detailVc.title = searchResult.description
        navigationController?.pushViewController(detailVc, animated: true)
    }
}
/// UI TableView
extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.watchlistArray.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else {
            fatalError("Cell not found")
        }

        let viewModel = viewModel.watchlistArray.value[indexPath.row]
        cell.viewModel = viewModel
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  WatchListTableViewCell.preferredHight
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let symbol = viewModels[indexPath.row].symbol
            PersistenceManager.shared.removeFromWatchList(symbol: symbol)
            watchListMap.removeValue(forKey: symbol)
            viewModels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TapManager.shared.vibrateForSelection()
        let viewModel = viewModel.watchlistArray.value[indexPath.row]
        let detailVC = DetailViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName
        )

        detailVC.title = viewModel.companyName
        navigationController?.pushViewController(detailVC, animated: true)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.headerView
        headerView.backgroundColor = UIColor.systemBackground
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
extension WatchListViewController: WatchListTableViewCellDelegate {
    func didUpdatedMaxWith() {
        tableView.reloadData()
    }
}
