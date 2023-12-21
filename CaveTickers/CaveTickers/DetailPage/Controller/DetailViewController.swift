//
//  DetailViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/16.
//

import UIKit
import SwiftUI
import XCAStocksAPI
import SafariServices

class DetailViewController: LoadingViewController, URLSessionWebSocketDelegate {
    // MARK: - Properties
    private var news: [NewsModel] = []
    private var viewModel = NewsViewModel()
    private let symbol: String
    private let companyName: String
    private var chartView = UIView()
    var closedPrice: String?
    let tableView = UITableView()
    // MARK: - Init
    init(
        symbol: String,
        companyName: String
    ) {
        self.symbol = symbol
        self.companyName = companyName
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTableView()
        checkStockExist()
        setupSwiftUIHeaderView()
        setupViewModelBinding()
        checkStockExist()
        viewModel.fetchNews()
    }
    // MARK: - Private
    private func setupViewModelBinding() {
        viewModel.news.bind { [weak self] _ in
            self?.tableView.reloadData()
            self?.hideLoadingView()
        }
    }
    private func setUpTableView() {
        view.addSubview(tableView)
        DispatchQueue.main.async { [weak self] in
            self?.checkStockExist()
        }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identfier)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(
            frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100)
        )
    }
    private func setupSwiftUIHeaderView() {
        let chartVM = ChartViewModel(ticker: Ticker(symbol: symbol), apiService: XCAStocksAPI())
        let stockTickerView = StockTickerView(chartVM: chartVM)
        let hostingController = UIHostingController(rootView: stockTickerView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.heightAnchor.constraint(equalToConstant: 350)
        ])
        tableView.tableHeaderView = hostingController.view
        updateTableViewConstraints()

        DispatchQueue.main.async { [weak self] in
            self?.checkStockExist()
        }
    }
    private func updateTableViewConstraints() {
        NSLayoutConstraint.deactivate(tableView.constraints)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 300),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    private func open(url: URL) {
        let SFvc = SFSafariViewController(url: url)
        present(SFvc, animated: true)
    }
    private func checkStockExist() {
        let isStockInWatchlist = PersistenceManager.shared.watchlistContains(symbol: symbol)
        if let headerView = tableView.tableHeaderView as? NewsHeaderView {
            headerView.button.isHidden = isStockInWatchlist
            }
        tableView.reloadData()
        }
}
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.news.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identfier,
            for: indexPath
        )as? NewsTableViewCell else {
            fatalError("cell connected failed")
        }
        cell.viewModel = viewModel.news.value[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: NewsHeaderView.identifier
        ) as? NewsHeaderView else {
            return nil
        }
        header.configure(with: .init(
            title: symbol,
            shouldShowAddButton: true
        ))
        header.priceLabel.text = self.closedPrice
        header.delegate = self
        return header
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsTableViewCell.preferredHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        TapManager.shared.vibrateForSelection()
        let story = viewModel.news.value[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFailedToOpenAlert()
            return
        }
        open(url: url)
    }
    private func presentFailedToOpenAlert() {
        TapManager.shared.vibrate(for: .error)

        let alert = UIAlertController(
            title: "Unable to Open",
            message: "We were unable to open the article.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
extension DetailViewController: DetailHeaderViewDelegate {
    func updateButtonStatus(_ headerView: NewsHeaderView) {
        let isStockInWatchlist = PersistenceManager.shared.watchlistContains(symbol: symbol)
        headerView.button.isHidden = isStockInWatchlist
    }
    func didTapAddButton(_ headerView: NewsHeaderView) {
        TapManager.shared.vibrate(for: .success)
        headerView.button.isHidden = true
        PersistenceManager.shared.addToWatchList(symbol: symbol, companyName: companyName)
        let alert = UIAlertController(
            title: "Added to Watchlist",
            message: "We've added \(companyName) to your watchlist.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
