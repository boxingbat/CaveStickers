//
//  AddToPortfolioController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/19.
//

import UIKit
import Combine

class AddToPortfolioController: LoadingViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: AddToPortfolioControllerDelegate?

    var tableView = UITableView()
    var dataEntries: [String] = ["test"]
    let addButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)

    var newSavingStock = SavedPortfolio(symbol: "", initialInput: 0, monthlyInpuy: 0, timeline: 0)
    var asset: Asset?
    var monthlyAdjusted: TimeSeriesMonthlyAdjusted?
    var dateIndex: Int?
    var computedresult: DCAResult?
    var resultSymbol: String?

    private var subscribers = Set<AnyCancellable>()
    private let portfolioManager = PortfolioManager()
    private let calculatorPresenter = CalculatorPresenter()

    @Published  var initialSymbol: String?
    @Published  var initialDateOfInvestmentIndex: Int?
    @Published  var initialInvestmentAmount: Int?
    @Published  var monthlyDollarCostAveragingAmount: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        setupSaveButton()
        setupCombineSubscriptions()
    }

    private func setupCombineSubscriptions() {
        Publishers.CombineLatest4(
            $initialSymbol,
            $initialInvestmentAmount,
            $monthlyDollarCostAveragingAmount,
            $initialDateOfInvestmentIndex)
        .sink { [weak self] symbol, investmentAmount, monthlyAmount, dateIndex in
            print(symbol ?? "", investmentAmount ?? 0, monthlyAmount ?? 0, dateIndex ?? 10)
            guard let self = self,
                let symbol = symbol,
                let investmentAmount = investmentAmount,
                let monthlyAmount = monthlyAmount,
                let dateIndex = dateIndex,
                let monthlyAdjusted = self.monthlyAdjusted else {
                print("Error: Monthly adjusted data is nil")
                return
            }
            let result = self.portfolioManager.calculate(
                monthlyAdjusted: monthlyAdjusted,
                initialInvestment: Double(investmentAmount),
                monthlyCost: Double(monthlyAmount),
                initialDateOfInvestmentIndex: dateIndex)
            print("result\(result)")

            newSavingStock.symbol = symbol
            newSavingStock.initialInput = Double(investmentAmount)
            newSavingStock.monthlyInpuy = Double(monthlyAmount)
            newSavingStock.timeline = dateIndex

            computedresult = result
            resultSymbol = symbol
            tableView.reloadData()
        }
        .store(in: &subscribers)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        ])

        tableView.register(AddPortfolioTableViewCell.self, forCellReuseIdentifier: "CustomCell")
    }

    @objc private func addNewCell() {
        dataEntries.append("")
        let indexPath = IndexPath(row: dataEntries.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    private func setupSaveButton() {
        saveButton.setImage(UIImage(systemName: "square.and.arrow.up.fill"), for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            saveButton.widthAnchor.constraint(equalToConstant: 50),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    @objc private func saveButtonTapped() {
        TapManager.shared.vibrateForSelection()
        PersistenceManager.shared.addPortfolio(savingStock: newSavingStock)
        print("Save\(String(describing: newSavingStock))")
        delegate?.didSavePortfolio()
        navigationController?.popViewController(animated: true)
    }

    private func fetchMonthlyAdjustedData(for symbol: String) {
        self.showLoadingView()
        APIManager.shared.monthlyAdjusted(for: symbol, keyNumber: Int.random(in: 11...17)) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleAPIResult(result)
            }
        }
    }

    private func handleAPIResult(_ result: Result<TimeSeriesMonthlyAdjusted, Error>) {
        switch result {
        case .success(let response):
            self.monthlyAdjusted = response
            let dateTableViewController = DateTableViewController()
            dateTableViewController.timeSeriesMonthlyAdjusted = response
            dateTableViewController.didSelectDate = { [weak self] selectedIndex in
                self?.dateIndex = selectedIndex
                self?.calculateAndDisplayResult(forDateIndex: selectedIndex)
            }
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(dateTableViewController, animated: true)
            }

        case .failure(let error):
            print(error)
        }
        self.hideLoadingView()
    }
    private func calculateAndDisplayResult(forDateIndex dateIndex: Int) {
        guard let symbol = initialSymbol,
            let investmentAmount = initialInvestmentAmount,
            let monthlyAmount = monthlyDollarCostAveragingAmount,
            let monthlyAdjusted = monthlyAdjusted else {
            print("Error: Required data is missing")
            return
        }

        let result = portfolioManager.calculate(
            monthlyAdjusted: monthlyAdjusted,
            initialInvestment: Double(investmentAmount),
            monthlyCost: Double(monthlyAmount),
            initialDateOfInvestmentIndex: dateIndex
        )
        newSavingStock.symbol = symbol
        newSavingStock.initialInput = Double(investmentAmount)
        newSavingStock.monthlyInpuy = Double(monthlyAmount)
        newSavingStock.timeline = dateIndex

        computedresult = result
        resultSymbol = symbol
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataEntries.count
    }
    // swiftlint:disable all
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! AddPortfolioTableViewCell
            // swiftlint:enable all
            cell.timeLineInputTextField.delegate = self
            cell.delegate = self
            cell.titleLabel.text = resultSymbol
            cell.titleLabel.text = resultSymbol

            if let computedResult = computedresult {
                let presentation = calculatorPresenter.getPresentation(result: computedResult)

                cell.titleLabel.text = resultSymbol
                cell.currentLabel.text = "\(computedResult.currentValue)"
                cell.investmentAmountLabel.text = "\(computedResult.investmentAmount)"
                cell.gainLabel.text = "\(computedResult.gain)"
                cell.annualReturnLabel.text = "\(computedResult.annualReturn)%"
                cell.yieldLabel.text = "\(computedResult.yield)%"
                cell.timeLineLabel.text = "Touch to choose"
                cell.yieldLabel.textColor = presentation.yieldLabelTextColor
                cell.annualReturnLabel.textColor = presentation.annualReturnLabelTextColor
            }

            return cell
    }
    // MARK: - Navigation
}
extension AddToPortfolioController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let cell = textField.superview?.superview as? AddPortfolioTableViewCell {
            if textField == cell.timeLineInputTextField {
                guard let symbol = cell.symbolTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                    !symbol.isEmpty else {
                    presentAlertWithTitle(title: "Hey", message: "Input the symbol")
                    return false
                }

                fetchMonthlyAdjustedData(for: symbol)
                return false
            }
        }
        return true
    }
    private func presentAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AddToPortfolioController: AddPortfolioTableViewCellDelegate {
    func textFieldDidChange(text: String?, textFieldType: PortfolioTextFieldType, cell: AddPortfolioTableViewCell) {
        switch textFieldType {
        case .symbol:
            initialSymbol = text
            newSavingStock.symbol = text ?? ""
            print("symbol update\(String(describing: text))")
        case .initialAmount:
            initialInvestmentAmount = Int(text ?? "")
            newSavingStock.initialInput = Double(initialInvestmentAmount ?? 0)
            print("initialAmount update\(String(describing: text))")
        case .monthlyInput:
            monthlyDollarCostAveragingAmount = Int(text ?? "")
            newSavingStock.monthlyInpuy = Double(monthlyDollarCostAveragingAmount ?? 0)
            print("Monthly update\(String(describing: text))")
        case .timeLine:
            initialDateOfInvestmentIndex = Int(text ?? "")
            newSavingStock.timeline = initialDateOfInvestmentIndex ?? 0
            print("timeline\(String(describing: text))")
        }
    }
}

protocol AddToPortfolioControllerDelegate: AnyObject {
    func didSavePortfolio()
}
