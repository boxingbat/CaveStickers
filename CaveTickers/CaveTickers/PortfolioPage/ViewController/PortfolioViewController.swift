//
//  PortfolioViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import UIKit
import SwiftUI
import Combine

class PortfolioViewController: LoadingViewController, AddToPortfolioControllerDelegate {
    weak var delegate: AddToPortfolioControllerDelegate?
    let tableView = UITableView()
    private var viewModel = PortfolioViewModel()
    private var pieChartView: PortfolioPieChart?
    private var pieChartViewModel = PieChartViewModel()
    private var subscribers = Set<AnyCancellable>()
    private var hostingController: UIHostingController<PortfolioPieChart>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = UIColor(named: "AccentColor")
        setupLayout()
        showLoadingView()
        setupViewModelBindings()
        viewModel.loadPortfolio()
        pieChartView = PortfolioPieChart(viewModel: pieChartViewModel)
        hostingController = pieChartView.map { UIHostingController(rootView: $0) }
        setupHeaderView()
    }
    private func setupViewModelBindings() {
        viewModel.$calculatedResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscribers)

        viewModel.$pieChartViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pieChartViewModel in
                self?.updatePieChartView(with: pieChartViewModel)
            }
            .store(in: &subscribers)
        viewModel.dataLoadedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hideLoadingView()
            }
            .store(in: &subscribers)
    }
    private func updatePieChartView(with viewModel: PieChartViewModel) {
        let newPieChartView = PortfolioPieChart(viewModel: viewModel)
        if let hostingController = self.hostingController {
            hostingController.rootView = newPieChartView
        } else {
            let newHostingController = UIHostingController(rootView: newPieChartView)
            self.hostingController = newHostingController
            setupHeaderView()
        }
    }
    private func setupHeaderView() {
        guard let hostingController = hostingController else { return }

        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width - 32, height: 400)
        tableView.tableHeaderView = headerView

        addChild(hostingController)
        headerView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            hostingController.view.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10)
        ])
    }
    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width - 32, height: 300)
        tableView.tableHeaderView = headerView

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let addButton = UIButton()
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(systemName: "plus.square.fill.on.square.fill"), for: .normal)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 75),
            addButton.heightAnchor.constraint(equalToConstant: 75)
        ])
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        tableView.register(StockTableViewCell.self, forCellReuseIdentifier: "StockCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    // MARK: - Navigation
    @objc private func addButtonTapped() {
        TapManager.shared.vibrateForSelection()
        let addPortfolioVC = AddToPortfolioController()
        addPortfolioVC.delegate = self
        navigationController?.pushViewController(addPortfolioVC, animated: true)
    }
    func didSavePortfolio() {
        viewModel.loadPortfolio()
    }
}
extension PortfolioViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return viewModel.savedPortfolio.count
        }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint: disable all
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockTableViewCell
        // swiftlint: enable all
        if indexPath.row < viewModel.calculatedResult.count {
            let result = viewModel.calculatedResult[indexPath.row]
            let saved = viewModel.savedPortfolio[indexPath.row]
            cell.stockInfoLabel.text = "\(saved.symbol)"
            cell.investmentAmountLabel.text = "\(result.investmentAmount)"
            cell.gainLabel.text = "\(result.gain)"
            cell.yieldLabel.text = "\(result.yield)%"
            cell.yieldLabel.textColor = result.isProfitable ? UIColor(Color.themeGreen) : UIColor(Color.themeRed)
            cell.annualReturnLabel.text = "\(result.annualReturn)%"
            cell.annualReturnLabel.textColor = result.isProfitable ? UIColor(Color.themeGreen) : UIColor(Color.themeRed)
        }
        return cell
    }
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let portfolioToDelete = viewModel.savedPortfolio[indexPath.row]
            viewModel.savedPortfolio.remove(at: indexPath.row)
            viewModel.calculatedResult.remove(at: indexPath.row)

            PersistenceManager.shared.deletePortfolio(savingStock: portfolioToDelete)

            tableView.deleteRows(at: [indexPath], with: .fade)
            viewModel.loadPortfolio()
        }
    }
}
