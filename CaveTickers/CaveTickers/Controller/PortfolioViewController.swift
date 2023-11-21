//
//  PortfolioViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import UIKit

class PortfolioViewController: UIViewController {

    let tableView = UITableView()
    private let portfolioManager = PortfolioManager()
    var savedPortfolio: [SavingPortfolio] = []
    var HistoryData: [TimeSeriesMonthlyAdjusted] = []
    var calculatedResult: [DCAResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadPortfolio()
    }

//    override func viewWillAppear(_ animated: Bool) {
//        loadPortfolio()
//    }

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
        HistoryData.removeAll()
        calculatedResult.removeAll()

        let group = DispatchGroup()

        for portfolio in savedPortfolio {
            group.enter()
            getHistoricData(symbol: portfolio.symbol) {
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.tableView.reloadData()
        }
    }


    func getHistoricData(symbol: String, completion: @escaping () -> Void) {
        APIManager.shared.monthlyAdjusted(for: symbol, keyNumber: 1) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.HistoryData.append(response)
                    if let portfolioItem = self?.savedPortfolio.first(where: { $0.symbol == symbol }) {
                        let result = self?.portfolioManager.calculate(
                            timeSeriesMonthlyAdjusted: response,
                            initialInvestmentAmount: portfolioItem.InitialInput,
                            monthlyDollarCostAveragingAmount: portfolioItem.MonthlyInpuy,
                            initialDateOfInvestmentIndex: portfolioItem.timeline
                        )
                        if let result = result {
                            self?.calculatedResult.append(result)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
                completion()
            }
        }
    }



    // MARK: - Navigation
    @objc private func addButtonTapped() {
        let addPortfolioVC = AddToPortfolioController()
        navigationController?.pushViewController(addPortfolioVC, animated: true)
    }

}


extension PortfolioViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculatedResult.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockTableViewCell
        if indexPath.row < calculatedResult.count {
            let result = calculatedResult[indexPath.row]
            let saved = savedPortfolio[indexPath.row]

            cell.stockInfoLabel.text = "\(saved.symbol)"
            cell.changeRateLabel.text = "Return: \(result.yield)%"
            cell.changeRateLabel.textColor = result.isProfitable ? .systemGreen : .systemRed
        }
        return cell
    }
}
