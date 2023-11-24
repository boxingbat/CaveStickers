//
//  DetailViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/16.
//

import UIKit
import SwiftUI

class DetailViewController: UIViewController, URLSessionWebSocketDelegate {
    // MARK: - Properties
    private let symbol: String
//    private let quoteVM: TickerQuoteViewModel

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

    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    private var metrics: Metrics?
    // MARK: - Init
    init(
        symbol: String,
        companyName: String,
        candleStickData: [CandleStick] = []
        //            quoteVM: TickerQuoteViewModel
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

//        let stockTickerView = StockTickerView(quoteVM: self.quoteVM)
//
//                let hostingController = UIHostingController(rootView: stockTickerView)
//
//                addChild(hostingController)
//                view.addSubview(hostingController.view)
//                hostingController.didMove(toParent: self)
//
//                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//                NSLayoutConstraint.activate([
//                    hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//                    hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                    hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                    hostingController.view.heightAnchor.constraint(equalToConstant: 300) // 设置合适的高度
//                ])
    }
    // MARK: - Private
    private func setupPriceLabel() {
        view.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
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
        //            webSocketManager.connect(withSymbol: symbol)
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
        // Fetch financial metrics
        group.enter()
        APIManager.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let response):
                let metrics = response.metric
                print(metrics)
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) { [weak self] in
//            self?.renderChart()
        }
    }
//    private func renderChart() {
//        // Chart VM | FinancialMetricViewModel(s)
//        let headerView = StockDetailHeaderView(
//            frame: CGRect(
//                x: 0,
//                y: 0,
//                width: view.width,
//                height: (view.width * 0.7) + 100
//            )
//        )
//        headerView.delegate = self
//        var viewModels: [MetricCollectionViewCell.ViewModel] = []
//        if let metrics = metrics {
//            viewModels.append(.init(name: "52W High", value: "\(metrics.annualWeekHigh)"))
//            viewModels.append(.init(name: "52L High", value: "\(metrics.annualWeekLow)"))
//            viewModels.append(.init(name: "52W Return", value: "\(metrics.annualWeekPriceReturnDaily)"))
//            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
//            viewModels.append(.init(name: "10D Vol.", value: "\(metrics.tenDayAverageTradingVolume)"))
//        }
//        // Configure
//        let change = candleStickData.getPercentage()
//        headerView.configure(
//            chartViewModel: .init(
//                data: candleStickData.reversed().map { $0.close },
//                showLegend: true,
//                showAxis: true,
//                fillColor: change < 0 ? .systemRed : .systemGreen
//            ),
//            metricViewModels: viewModels
//        )
//        headerView.backgroundColor = .systemBackground
//        tableView.tableHeaderView = headerView
//        tableView.reloadData()
//    }
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
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
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
