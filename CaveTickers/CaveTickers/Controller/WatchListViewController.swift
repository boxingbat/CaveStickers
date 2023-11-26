//
//  ViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import UIKit

class WatchListViewController: UIViewController {
    static var maxChangeWidth: CGFloat = 0

    private var searchTimer: Timer?
    private var watchListMap: [String: [CandleStick]] = [:]
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        return tableView
    }()

    private var observer: NSObjectProtocol?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchController()
        setupTableView()
        setupTitleView()
        fetchWatchlistData()
        setUpObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    // MARK: - Private
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchList, object: nil, queue: .main, using: {[weak self]_ in
            self?.viewModels.removeAll()
            self?.fetchWatchlistData()
        })
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
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 32, weight: .medium)
        titleView.addSubview(label)

        navigationItem.titleView = titleView
    }

    private func fetchWatchlistData() {
        let symbols = PersistenceManager.shared.watchlist

        let group = DispatchGroup()

        for symbol in symbols where watchListMap[symbol] == nil {
            group.enter()

            APIManager.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }

                switch result {
                case .success(let data):
                    let candleStickers = data.candleSticks
                    self?.watchListMap[symbol] = candleStickers
                case .failure(let error):
                    print(error)
                }

            }
        }
        group.notify(queue: .main) {[weak self] in
            self?.craeteViewModels()
            self?.tableView.reloadData()
        }
    }

    private func craeteViewModels() {
        var viewModels: [WatchListTableViewCell.ViewModel] = []
        for (symbol, candleSticks) in watchListMap {
            let changePersentage = getChangePercentage(symbol: symbol, data: candleSticks)
            viewModels.append(
                .init(
                    symbol: symbol,
                    price: getLatestClosingPrice(from: candleSticks),
                    changeColor: changePersentage < 0 ? .systemRed : .systemGreen,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                    changePercentage: String.percentage(from: changePersentage)
                )
            )

        }

        self.viewModels = viewModels
    }

    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
            let priorClose = data.first(where: {
                !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
            })?.close else {
            return 0
        }
        print("\(symbol): Current: \(latestDate):\(latestClose) | Prior:\(priorClose)")
        let differnece = 1 - priorClose / latestClose
        return differnece
    }

    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        return String.formatted(number: closingPrice)
    }
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
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

        let detailVc = DetailViewController(
            symbol: searchResult.symbol,
            companyName: searchResult.description,
            candleStickData: []
        )
        detailVc.title = searchResult.description
        navigationController?.pushViewController(detailVc, animated: true)
    }
}
extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchListMap.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else {
            fatalError("error")
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  WatchListTableViewCell.preferredHight
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        let viewModel = viewModels[indexPath.row]
        let detailVC = DetailViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleStickData: watchListMap[viewModel.symbol] ?? [])
        let navVC = UINavigationController(rootViewController: detailVC)
        detailVC.title = viewModel.companyName
        present(navVC, animated: true)
    }
}
extension WatchListViewController: WatchListTableViewCellDelegate {
    func didUpdatedMaxWith() {
        tableView.reloadData()
    }
}
