//
//  PortfolioViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import UIKit
import SwiftUI

class PortfolioViewController: UIViewController, AddToPortfolioControllerDelegate {
    weak var delegate: AddToPortfolioControllerDelegate?
    let tableView = UITableView()
    private let portfolioManager = PortfolioManager()
    var savedPortfolio: [SavingPortfolio] = []
    var historyData: [TimeSeriesMonthlyAdjusted] = []
    var calculatedResult: [DCAResult] = []
    var pieChartView: PortfolioPieChart?
    var pieChartViewModel = PieChartViewModel()
    var hostingController: UIHostingController<PortfolioPieChart>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadPortfolio()

        pieChartView = PortfolioPieChart(viewModel: pieChartViewModel)
        hostingController = UIHostingController(rootView: pieChartView!)

        setupHeaderView()
    }

    private func setupHeaderView() {
        guard let hostingController = hostingController else { return }

        let headerView = UIView()
        headerView.backgroundColor = .link
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width - 32, height: 250)
        tableView.tableHeaderView = headerView

        addChild(hostingController)
        headerView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: headerView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
    }



    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)


        let headerView = UIView()
        headerView.backgroundColor = .link
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width - 32, height: 250)


        tableView.tableHeaderView = headerView

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let addButton = UIButton(type: .custom)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.backgroundColor = .blue
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        addButton.layer.cornerRadius = 25
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        tableView.register(StockTableViewCell.self, forCellReuseIdentifier: "StockCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func loadPortfolio() {
        let savedStocks = PersistenceManager.shared.loadPortfolio()
        savedPortfolio = savedStocks
        print(savedPortfolio)
        historyData.removeAll()
        calculatedResult.removeAll()

        var tempResults: [String: DCAResult] = [:]
        let group = DispatchGroup()

        for portfolio in savedPortfolio {
            group.enter()
            getHistoricData(symbol: portfolio.symbol) { [weak self] result in
                guard let strongSelf = self else { return }
                if let result = result {
                    tempResults[portfolio.symbol] = result
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
    strongSelf.calculatedResult = strongSelf.savedPortfolio.compactMap { tempResults[$0.symbol] }
        // 创建包含 symbol 和 DCAResult 的 PortfolioItem 数组
            let portfolioItems = strongSelf.savedPortfolio.enumerated().compactMap { index, savedItem -> PortfolioItem? in
                guard index < strongSelf.calculatedResult.count else { return nil }
                return PortfolioItem(symbol: savedItem.symbol, dcaResult: strongSelf.calculatedResult[index])
            }
            strongSelf.pieChartViewModel.updateChart(with: portfolioItems)
            strongSelf.tableView.reloadData()
        }
    }



    func getHistoricData(symbol: String, completion: @escaping (DCAResult?) -> Void) {
        APIManager.shared.monthlyAdjusted(for: symbol, keyNumber: 1) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.historyData.append(response)
                    if let portfolioItem = self?.savedPortfolio.first(where: { $0.symbol == symbol }) {
                        let result = self?.portfolioManager.calculate(
                            timeSeriesMonthlyAdjusted: response,
                            initialInvestmentAmount: portfolioItem.initialInput,
                            monthlyDollarCostAveragingAmount: portfolioItem.monthlyInpuy,
                            initialDateOfInvestmentIndex: portfolioItem.timeline
                        )
                        completion(result)
                    }
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
        }
    }



    // MARK: - Navigation
    @objc private func addButtonTapped() {
        let addPortfolioVC = AddToPortfolioController()
        addPortfolioVC.delegate = self
        navigationController?.pushViewController(addPortfolioVC, animated: true)
    }
    func didSavePortfolio() {
        loadPortfolio()
    }
}


extension PortfolioViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return calculatedResult.count
        }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint: disable all
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockTableViewCell
        // swiftlint: enable all
        if indexPath.row < calculatedResult.count {
            let result = calculatedResult[indexPath.row]
            let saved = savedPortfolio[indexPath.row]

            cell.stockInfoLabel.text = "\(saved.symbol)"
            cell.investmentAmountLabel.text = "\(result.investmentAmount)"
            cell.gainLabel.text = "\(result.gain)"
            cell.gainLabel.textColor = result.isProfitable ? .systemGreen : .systemRed
            cell.yieldLabel.text = "\(result.yield)"
            cell.yieldLabel.textColor = result.isProfitable ? .systemGreen : .systemRed
            cell.annualReturnLabel.text = "\(result.annualReturn)"
            cell.annualReturnLabel.textColor = result.isProfitable ? .systemGreen : .systemRed
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let portfolioToDelete = savedPortfolio[indexPath.row]
            savedPortfolio.remove(at: indexPath.row)
            calculatedResult.remove(at: indexPath.row)

            PersistenceManager.shared.deletePortfolio(savingStock: portfolioToDelete)

            tableView.deleteRows(at: [indexPath], with: .fade)
            setupHeaderView()
        }
    }
}
