//
//  PortfolioTableViewCell.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/19.
//

import UIKit

class StockTableViewCell: UITableViewCell {
    let stockInfoLabel = UILabel()
    // Title
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

    // Data
    var investmentAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    var gainLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    var yieldLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    var annualReturnLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCellLayout()
    }

    private func setupCellLayout() {
        stockInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        investedAmnountTitle.translatesAutoresizingMaskIntoConstraints = false
        gainTitle.translatesAutoresizingMaskIntoConstraints = false
        yieldTitle.translatesAutoresizingMaskIntoConstraints = false
        annualReturnTitle.translatesAutoresizingMaskIntoConstraints = false
        investmentAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        gainLabel.translatesAutoresizingMaskIntoConstraints = false
        yieldLabel.translatesAutoresizingMaskIntoConstraints = false
        annualReturnLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stockInfoLabel)
        addSubview(investedAmnountTitle)
        addSubview(gainTitle)
        addSubview(yieldTitle)
        addSubview(annualReturnTitle)
        addSubview(investmentAmountLabel)
        addSubview(gainLabel)
        addSubview(yieldLabel)
        addSubview(annualReturnLabel)

        NSLayoutConstraint.activate([
            stockInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stockInfoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            investedAmnountTitle.leadingAnchor.constraint(equalTo: stockInfoLabel.leadingAnchor),
            investedAmnountTitle.topAnchor.constraint(equalTo: stockInfoLabel.bottomAnchor, constant: 4),

            investmentAmountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            investmentAmountLabel.centerYAnchor.constraint(equalTo: investedAmnountTitle.centerYAnchor),

            gainTitle.leadingAnchor.constraint(equalTo: stockInfoLabel.leadingAnchor),
            gainTitle.topAnchor.constraint(equalTo: investedAmnountTitle.bottomAnchor, constant: 4),

            gainLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            gainLabel.centerYAnchor.constraint(equalTo: gainTitle.centerYAnchor),

            yieldTitle.leadingAnchor.constraint(equalTo: stockInfoLabel.leadingAnchor),
            yieldTitle.topAnchor.constraint(equalTo: gainTitle.bottomAnchor, constant: 4),

            yieldLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            yieldLabel.centerYAnchor.constraint(equalTo: yieldTitle.centerYAnchor),

            annualReturnTitle.leadingAnchor.constraint(equalTo: stockInfoLabel.leadingAnchor),
            annualReturnTitle.topAnchor.constraint(equalTo: yieldTitle.bottomAnchor, constant: 4),

            annualReturnLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            annualReturnLabel.centerYAnchor.constraint(equalTo: annualReturnTitle.centerYAnchor),

        ])
    }
}
