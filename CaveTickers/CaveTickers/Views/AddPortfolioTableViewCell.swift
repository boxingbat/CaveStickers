//
//  CustomTableViewCell.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/19.
//

import UIKit
import Combine

class AddPortfolioTableViewCell: UITableViewCell {
    
    //title
    var investedAmnountTitle: UILabel = {
        let label = UILabel()
        label.text = "Invested Amnount"
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    var gainTitle: UILabel = {
        let label = UILabel()
        label.text = "Gain"
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    var yieldTitle: UILabel = {
        let label = UILabel()
        label.text = "Yield Percentange"
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    var annualReturnTitle: UILabel = {
        let label = UILabel()
        label.text = "Annual Return"
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    //Data
    var titleLabel = UILabel()
    var currentLabel = UILabel()
    var investmentAmountLabel = UILabel()
    var gainLabel = UILabel()
    var yieldLabel = UILabel()
    var annualReturnLabel = UILabel()
    let symbolLabel = UILabel()
    let symbolTextField = UITextField()

    //User Input
    let initialAmountLabel = UILabel()
    let initialAmountTextField = UITextField()
    let MonthlyInputLabel = UILabel()
    let MonthlyInputTextField = UITextField()
    let TimeLineLabel = UILabel()
    let TimeLineInputTextField = UITextField()
    let userInput: [UserInput] = []
    let protfolioDetail: [PortfolioDetail] = []

    var timeLineText: String? {
            didSet {
                textFieldDidChange(TimeLineInputTextField)
            }
        }

    weak var delegate: AddPortfolioTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        configureWithData()
        configureStyle()
        selectionStyle = .none
        setupTextFields()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
        configureWithData()

    }

    func updateTimeLineText(with text: String) {
            TimeLineInputTextField.text = text
            textFieldDidChange(TimeLineInputTextField)
        }
    private func setupTextFields() {
            symbolTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            initialAmountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            MonthlyInputTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            TimeLineInputTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .allEvents)
        }

        @objc private func textFieldDidChange(_ textField: UITextField) {
            let textFieldType: PortfolioTextFieldType
            switch textField {
            case symbolTextField:
                textFieldType = .symbol
            case initialAmountTextField:
                textFieldType = .initialAmount
            case MonthlyInputTextField:
                textFieldType = .monthlyInput
            case TimeLineInputTextField:
                textFieldType = .timeLine
            default:
                return
            }
            delegate?.textFieldDidChange(text: textField.text, textFieldType: textFieldType, cell: self)
        }

    private func setupCell() {
        let components = [titleLabel, currentLabel, investmentAmountLabel, gainLabel, annualReturnLabel,symbolLabel,symbolTextField,initialAmountLabel,initialAmountTextField,MonthlyInputLabel,MonthlyInputTextField,TimeLineLabel,TimeLineInputTextField,gainTitle, investedAmnountTitle, annualReturnTitle, yieldLabel, yieldTitle]
        for component in components {
            component.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(component)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            currentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            currentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            currentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            investmentAmountLabel.topAnchor.constraint(equalTo: currentLabel.bottomAnchor, constant: 8),
            investmentAmountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            investedAmnountTitle.centerYAnchor.constraint(equalTo: investmentAmountLabel.centerYAnchor),
            investedAmnountTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),


            gainLabel.topAnchor.constraint(equalTo: investmentAmountLabel.bottomAnchor, constant: 8),
            gainLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            gainTitle.centerYAnchor.constraint(equalTo: gainLabel.centerYAnchor),
            gainTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            yieldLabel.topAnchor.constraint(equalTo: gainTitle.bottomAnchor, constant: 8),
            yieldLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            yieldTitle.centerYAnchor.constraint(equalTo: yieldLabel.centerYAnchor),
            yieldTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            annualReturnLabel.topAnchor.constraint(equalTo: yieldTitle.bottomAnchor, constant: 8),
            annualReturnLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            annualReturnTitle.centerYAnchor.constraint(equalTo: annualReturnLabel.centerYAnchor),
            annualReturnTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            symbolLabel.topAnchor.constraint(equalTo: annualReturnLabel.bottomAnchor, constant: 16),
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            symbolLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            symbolTextField.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 8),
            symbolTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            symbolTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            initialAmountLabel.topAnchor.constraint(equalTo: symbolTextField.bottomAnchor, constant: 8),
            initialAmountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            initialAmountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            initialAmountTextField.topAnchor.constraint(equalTo: initialAmountLabel.bottomAnchor, constant: 8),
            initialAmountTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            initialAmountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            MonthlyInputLabel.topAnchor.constraint(equalTo: initialAmountTextField.bottomAnchor, constant: 8),
            MonthlyInputLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            MonthlyInputLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            MonthlyInputTextField.topAnchor.constraint(equalTo: MonthlyInputLabel.bottomAnchor, constant: 16),
            MonthlyInputTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            MonthlyInputTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            TimeLineLabel.topAnchor.constraint(equalTo: MonthlyInputTextField.bottomAnchor, constant: 8),
            TimeLineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            TimeLineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            TimeLineInputTextField.topAnchor.constraint(equalTo: TimeLineLabel.bottomAnchor, constant: 8),
            TimeLineInputTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            TimeLineInputTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            TimeLineInputTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configureWithData() {
        titleLabel.text = "???"
        currentLabel.text = "0"
        investmentAmountLabel.text = "000"
        gainLabel.text = "00"
        yieldLabel.text = "0%"
        annualReturnLabel.text = "0%"
        symbolLabel.text = "Stock Symbol"

        initialAmountLabel.text = "initail Amount(USD)"
        MonthlyInputLabel.text = "MonthlyInput Amount(USD)"
        TimeLineLabel.text = "TimeLine(Months)"
    }

    func configureStyle() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        currentLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        investmentAmountLabel.font = UIFont.systemFont(ofSize: 12)
        gainLabel.font = UIFont.systemFont(ofSize: 12)
        yieldLabel.font = UIFont.systemFont(ofSize: 12)
        annualReturnLabel.font = UIFont.systemFont(ofSize: 12)

        symbolLabel.font = UIFont.systemFont(ofSize: 12)

        symbolTextField.font = UIFont.systemFont(ofSize: 24)
        symbolTextField.addDoneButton()
        symbolTextField.keyboardType = .default

        initialAmountLabel.font = UIFont.systemFont(ofSize: 12)

        initialAmountTextField.font = UIFont.systemFont(ofSize: 24)
        initialAmountTextField.addDoneButton()
        initialAmountTextField.keyboardType = .numberPad


        MonthlyInputLabel.font = UIFont.systemFont(ofSize: 12)

        MonthlyInputTextField.font = UIFont.systemFont(ofSize: 24)
        MonthlyInputTextField.addDoneButton()
        MonthlyInputTextField.keyboardType = .numberPad


        TimeLineLabel.font = UIFont.systemFont(ofSize: 12)

        TimeLineInputTextField.font = UIFont.systemFont(ofSize: 24)
    }
}

protocol AddPortfolioTableViewCellDelegate: AnyObject {
    func textFieldDidChange(text: String?, textFieldType: PortfolioTextFieldType, cell: AddPortfolioTableViewCell)
}

enum PortfolioTextFieldType {
    case symbol, initialAmount, monthlyInput, timeLine
}



