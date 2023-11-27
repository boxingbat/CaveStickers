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

class DetailViewController: UIViewController, URLSessionWebSocketDelegate {
    // MARK: - Properties

    private var news: [NewsStory] = []
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    private var chartView = UIView()
    private var webSocketManager = WebSocketManager()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.textColor = .black
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identfier)
        return table
    }()
    private var metrics: Metrics?
    // MARK: - Init
    init(
        symbol: String,
        companyName: String,
        candleStickData: [CandleStick] = []
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        //            self.quoteVM = quoteVM
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        webSocketManager.close()
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        fetchFinancialData()
        setUpTableView()
        webSocketManager.connect(withSymbol: symbol)
        setupPriceLabel()
        setupWebSocket()
        setupSwiftUIHeaderView()
        fetchNews()
    }
    // MARK: - Private
    private func setupPriceLabel() {
        view.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            priceLabel.widthAnchor.constraint(equalToConstant: 150),
            priceLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    private func setupWebSocket() {
        webSocketManager.onReceive = { [weak self] message in
            print("Received message: \(message)")
            DispatchQueue.main.async {
                self?.priceLabel.text = message
            }
        }
    }
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
    private func fetchFinancialData() {
        let group = DispatchGroup()
        // Fetch candle sticks if needed
        if candleStickData.isEmpty {
            group.enter()
            APIManager.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }

    }
    private func setupSwiftUIHeaderView() {
        let chartVM = ChartViewModel(ticker: Ticker(symbol: symbol), apiService: XCAStocksAPI())
        let quoteVM = TickerQuoteViewModel(ticker: Ticker(symbol: symbol), stocksAPI: XCAStocksAPI())

        let stockTickerView = StockTickerView(chartVM: chartVM, quoteVM: quoteVM)

        let hostingController = UIHostingController(rootView: stockTickerView)

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.heightAnchor.constraint(equalToConstant: 400)
        ])
        tableView.tableHeaderView = hostingController.view

        updateTableViewConstraints()
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

    private func fetchNews() {
        APIManager.shared.companyNews(symbol: symbol) { [weak self] result in
            switch result {
            case .success(let news):
                DispatchQueue.main.async {
                    self?.news = news
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    private func open(url: URL) {
        let SFvc = SFSafariViewController(url: url)
        present(SFvc, animated: true)
    }
}


extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identfier,
            for: indexPath
        )as? NewsTableViewCell else {
            fatalError("cell connected failed")
        }
        cell.configure(with: .init(model: news[indexPath.row]))
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
        )
        )
        return header
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsTableViewCell.preferredHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        HapticsManager.shared.vibrateForSelection()

        // Open news story
        let story = news[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFailedToOpenAlert()
            return
        }
        open(url: url)
    }
    private func presentFailedToOpenAlert() {
        HapticsManager.shared.vibrate(for: .error)

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
    func didTapAddButton(_ headerView: StockDetailHeaderView) {
        TapManager.shared.vibrate(for: .success)
        headerView.addButton.isHidden = true
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
