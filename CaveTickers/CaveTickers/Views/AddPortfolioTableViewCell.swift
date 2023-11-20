//
//  CustomTableViewCell.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/19.
//

import UIKit

class AddPortfolioTableViewCell: UITableViewCell {

    let titleLabel = UILabel()
    let currentLabel = UILabel()
    let investmentAmountLabel = UILabel()
    let gainLabel = UILabel()
    let annualReturnLabel = UILabel()
    let initialAmountLabel = UILabel()
    let initialAmountTextField = UITextField()
    let MonthlyInputLabel = UILabel()
    let MonthlyInputTextField = UITextField()
    let TimeLineLabel = UILabel()
    let TimeLineInputTextField = UITextField()
    let userInput: [UserInput] = []
    let protfolioDetail: [PortfolioDetail] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        configureWithData()
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
        configureWithData()

    }

    private func setupCell() {
        let components = [titleLabel, currentLabel, investmentAmountLabel, gainLabel, annualReturnLabel,initialAmountLabel,initialAmountTextField,MonthlyInputLabel,MonthlyInputTextField,TimeLineLabel,TimeLineInputTextField]
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
            investmentAmountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            gainLabel.topAnchor.constraint(equalTo: investmentAmountLabel.topAnchor),
            gainLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            annualReturnLabel.topAnchor.constraint(equalTo: investmentAmountLabel.bottomAnchor, constant: 8),
            annualReturnLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            annualReturnLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            initialAmountLabel.topAnchor.constraint(equalTo: annualReturnLabel.bottomAnchor, constant: 8),
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
        titleLabel.text = "APPL"
        currentLabel.text = "100"
        investmentAmountLabel.text = "1000"
        gainLabel.text = "100"
        annualReturnLabel.text = "10"
        initialAmountLabel.text = "initail Amount(USD)"
//        initialAmountTextField.text = "Import your initail Amount(USD)"
        MonthlyInputLabel.text = "MonthlyInput Amount(USD)"
//        MonthlyInputTextField.text = "Import your MonthlyInput Amount(USD)"
        TimeLineLabel.text = "TimeLine"
//        TimeLineInputTextField.text = "Import TimeLine)"

        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        currentLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        investmentAmountLabel.font = UIFont.systemFont(ofSize: 16)
        gainLabel.font = UIFont.systemFont(ofSize: 16)
        annualReturnLabel.font = UIFont.systemFont(ofSize: 16)
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

    struct DataType {
        var title: String
        var currentValue: Double
        var investmentAmount: Double
        var gain: Double
        var annualReturn: Double
    }
}



