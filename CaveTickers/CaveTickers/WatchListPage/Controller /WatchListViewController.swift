//
//  ViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import UIKit
import SwiftUI

class WatchListViewController: LoadingViewController {
    static var maxChangeWidth: CGFloat = 0
    private var searchTimer: Timer?
    private var watchListMap: [String: [CandleStick]] = [:]
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    private var tableView = UITableView()
    private var singleDayMap: [String: SingleDayResponse] = [:]
    private var companyInfo: [String: CompanyInfoResponse] = [:]

    private var observer: NSObjectProtocol?
    private var loadingStateVC: UIHostingController<LoadingStateView>?
    private var fetchedData = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UILabel.appearance().textColor = UIColor(named: "AccentColor")
        UIButton.appearance().setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "AccentColor") ?? .black]
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.backgroundColor = .systemBackground
        showLoadingView()
        setUpSearchController()
        setupTableView()
        setupTitleView()
        showLoadingView()
        fetchWatchlistData()
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
            fetchWatchlistData()
        }
    }
    // MARK: - Private
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .didAddToWatchList,
            object: nil,
            queue: .main) { [weak self]_ in
            self?.viewModels.removeAll()
            self?.fetchWatchlistData()
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
    private func fetchWatchlistData() {
        let symbols = PersistenceManager.shared.watchlist

        let group = DispatchGroup()

        for symbol in symbols where singleDayMap[symbol] == nil {
            group.enter()
            group.enter()

            APIManager.shared.singleDayData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }

                switch result {
                case .success(let data):
                    let data = data
                    self?.singleDayMap[symbol] = data
                case .failure(let error):
                    print(error)
                }
            }
            APIManager.shared.companyInfo(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }

                switch result {
                case .success(let data):
                    let data = data
                    self?.companyInfo[symbol] = data
                case .failure(let error):
                    print(error)
                }
            }
        }
        group.notify(queue: .main) {[weak self] in
            self?.craeteViewModels()
            self?.tableView.reloadData()
            self?.hideLoadingView()
            self?.fetchedData = false
        }
    }
    private func craeteViewModels() {
        var viewModels: [WatchListTableViewCell.ViewModel] = []
        for (symbol, singleDayResponse) in singleDayMap {
            if let companyInfoResponse = companyInfo[symbol] {
                let changeColor: UIColor = singleDayResponse.changePercent < 0 ? UIColor(named: "RedColor") ?? .systemRed : .systemGreen
                viewModels.append(
                    .init(
                        symbol: symbol,
                        price: "\(singleDayResponse.current)",
                        changeColor: changeColor,
                        companyName: "\(companyInfoResponse.name ?? symbol)",
                        changePercentage: singleDayResponse.changePercent.asPercentString(),
                        marketCaptital: companyInfoResponse.marketCapitalization?.formatUsingAbbrevation() ?? "",
                        shareOutstanding: companyInfoResponse.shareOutstanding?.formatUsingAbbrevation() ?? ""
                    )
                )
            }
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
            companyName: searchResult.description,
            candleStickData: []
        )
        _ = searchResult.symbol
        detailVc.title = searchResult.description
        navigationController?.pushViewController(detailVc, animated: true)
    }
}
extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WatchListTableViewCell.identifier,
            for: indexPath
        ) as? WatchListTableViewCell else {
            fatalError("error")
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        cell.backgroundColor = .systemBackground
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
        let viewModel = viewModels[indexPath.row]
        let detailVC = DetailViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleStickData: watchListMap[viewModel.symbol] ?? [])

        detailVC.title = viewModel.companyName
        navigationController?.pushViewController(detailVC, animated: true)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TableSectionHeaderView()
        headerView.backgroundColor = .systemBackground
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44 // Or whatever height you prefer
    }
}
extension WatchListViewController: WatchListTableViewCellDelegate {
    func didUpdatedMaxWith() {
        tableView.reloadData()
    }
}
class TableSectionHeaderView: UIView {
    private let stockLabel = UILabel()
    private let marketCapLabel = UILabel()
    private let priceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stockLabel)
        addSubview(marketCapLabel)
        addSubview(priceLabel)

        stockLabel.text = "Stock"
        marketCapLabel.text = "MarketCap"
        priceLabel.text = "Price"

        stockLabel.textColor = .gray
        marketCapLabel.textColor = .gray
        priceLabel.textColor = .gray

        stockLabel.font = .systemFont(ofSize: 12)
        marketCapLabel.font = .systemFont(ofSize: 12)
        priceLabel.font = .systemFont(ofSize: 12)

        stockLabel.translatesAutoresizingMaskIntoConstraints = false
        marketCapLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stockLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stockLabel.topAnchor.constraint(equalTo: topAnchor),
            stockLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            marketCapLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 30),
            marketCapLabel.topAnchor.constraint(equalTo: topAnchor),
            marketCapLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            priceLabel.topAnchor.constraint(equalTo: topAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
