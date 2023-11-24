//
//  AddToPortfolioController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/19.
//

import UIKit
import Combine

class AddToPortfolioController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: AddToPortfolioControllerDelegate?

    var tableView = UITableView()
    var dataEntries: [String] = ["test"]
    let addButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)

    var newSavingStock = SavingPortfolio(symbol: "", initialInput: 0, monthlyInpuy: 0, timeline: 0)


    var asset: Asset?
    var timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted?
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
        setupAddButton()
        setupCombineSubscriptions()
    }

    private func setupCombineSubscriptions() {
        Publishers.CombineLatest4($initialSymbol, $initialInvestmentAmount, $monthlyDollarCostAveragingAmount, $initialDateOfInvestmentIndex)
            .sink { [weak self] symbol, investmentAmount, monthlyAmount, dateIndex in
                print(symbol ?? "", investmentAmount ?? 0, monthlyAmount ?? 0, dateIndex ?? 10)
                guard let self = self,
                    let symbol = symbol,
                    let investmentAmount = investmentAmount,
                    let monthlyAmount = monthlyAmount,
                    let dateIndex = dateIndex
                else { return }

                let result = self.portfolioManager.calculate(timeSeriesMonthlyAdjusted: self.timeSeriesMonthlyAdjusted!, initialInvestmentAmount: Double(investmentAmount), monthlyDollarCostAveragingAmount: Double(monthlyAmount), initialDateOfInvestmentIndex: dateIndex)
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

    private func setupAddButton() {
        addButton.setTitle("+", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        addButton.addTarget(self, action: #selector(addNewCell), for: .touchUpInside)
    }

    @objc private func addNewCell() {
        dataEntries.append("")
        let indexPath = IndexPath(row: dataEntries.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    private func setupSaveButton() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    @objc private func saveButtonTapped() {
        PersistenceManager.shared.addPortfolio(savingStock: newSavingStock)
        print("Save\(String(describing: newSavingStock))")
        delegate?.didSavePortfolio()
        navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataEntries.count + 1
    }
    // swiftlint:disable all
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < dataEntries.count {
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

                cell.currentLabel.backgroundColor = presentation.currentValueLabelBackgroundColor
                cell.yieldLabel.backgroundColor = presentation.yieldLabelTextColor
                cell.annualReturnLabel.textColor = presentation.annualReturnLabelTextColor
            }

            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "SearchCell")
            let textField = UITextField(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height))
            textField.placeholder = "...Add More Stock"
            cell.contentView.addSubview(textField)
            return cell
        }
    }


    // MARK: - Navigation
}

extension AddToPortfolioController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let cell = textField.superview?.superview as? AddPortfolioTableViewCell {
            if textField == cell.timeLineInputTextField {
                guard let symbol = cell.symbolTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !symbol.isEmpty else {
                    presentAlertWithTitle(title: "Hey", message: "Input the symbol")
                    return false
                }

                let dateTableViewController = DateTableViewController()
                APIManager.shared.monthlyAdjusted(for: symbol, keyNumber: 2) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            let month = response.getMonthInfos()
                            print(month)
                            dateTableViewController.timeSeriesMonthlyAdjusted = response
                            self?.timeSeriesMonthlyAdjusted = response
                            dateTableViewController.didSelectDate = { [weak self] selectedIndex in
                                let monthInfos = response.getMonthInfos()
                                if selectedIndex < monthInfos.count {
                                    let selectedDateInfo = monthInfos[selectedIndex].date
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM"
                                    _ = dateFormatter.string(from: selectedDateInfo)
                                    self?.dateIndex = selectedIndex
                                    cell.updateTimeLineText(with: String(selectedIndex))
                                    cell.timeLineInputTextField.text = String(selectedIndex)
                                    print(cell.timeLineInputTextField)
                                }
                            }
                            self?.navigationController?.pushViewController(dateTableViewController, animated: true)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
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
            print("symbol update\(String(describing: text))")
        case .initialAmount:
            initialInvestmentAmount = Int(text ?? "")
            print("Initial Amount\(String(describing: text))")
        case .monthlyInput:
            monthlyDollarCostAveragingAmount = Int(text ?? "")
            print("Monthly input\(String(describing: text))")
        case .timeLine:
            initialDateOfInvestmentIndex = Int(text ?? "")
            print("timeline\(String(describing: text))")
        }
    }
}

protocol AddToPortfolioControllerDelegate: AnyObject {
    func didSavePortfolio()
}
