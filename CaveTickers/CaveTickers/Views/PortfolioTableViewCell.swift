//
//  PortfolioTableViewCell.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/19.
//

import UIKit
import SwiftUI

class StockTableViewCell: UITableViewCell {
    let stockInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)

        return label
    }()
    // Title
    var investedAmnountTitle: UILabel = {
        let label = UILabel()
        label.text = "Invested Amnount"
        label.textColor = UIColor(Color.theme.secondaryText)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    var gainTitle: UILabel = {
        let label = UILabel()
        label.text = "Gain"
        label.textColor = UIColor(Color.theme.secondaryText)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    var yieldTitle: UILabel = {
        let label = UILabel()
        label.text = "Yield Percentange"
        label.textColor = UIColor(Color.theme.secondaryText)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    var annualReturnTitle: UILabel = {
        let label = UILabel()
        label.text = "Annual Return"
        label.textColor = UIColor(Color.theme.secondaryText)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    // Data
    var investmentAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    var gainLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    var yieldLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(Color.theme.accent)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    var annualReturnLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(Color.theme.accent)
        label.font = UIFont.systemFont(ofSize: 20)
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
            investedAmnountTitle.topAnchor.constraint(equalTo: stockInfoLabel.bottomAnchor, constant: 12),

            investmentAmountLabel.leadingAnchor.constraint(equalTo: investedAmnountTitle.leadingAnchor),
            investmentAmountLabel.topAnchor.constraint(equalTo: investedAmnountTitle.bottomAnchor, constant: 8),

            gainTitle.leadingAnchor.constraint(equalTo: contentView.centerXAnchor),
            gainTitle.topAnchor.constraint(equalTo: investedAmnountTitle.topAnchor),

            gainLabel.leadingAnchor.constraint(equalTo: gainTitle.leadingAnchor),
            gainLabel.topAnchor.constraint(equalTo: gainTitle.bottomAnchor, constant: 8),

            yieldTitle.leadingAnchor.constraint(equalTo: stockInfoLabel.leadingAnchor),
            yieldTitle.topAnchor.constraint(equalTo: investmentAmountLabel.bottomAnchor, constant: 16),

            yieldLabel.leadingAnchor.constraint(equalTo: stockInfoLabel.leadingAnchor),
            yieldLabel.topAnchor.constraint(equalTo: yieldTitle.bottomAnchor, constant: 8),

            annualReturnTitle.leadingAnchor.constraint(equalTo: gainTitle.leadingAnchor),
            annualReturnTitle.topAnchor.constraint(equalTo: gainLabel.bottomAnchor, constant: 16),

            annualReturnLabel.leadingAnchor.constraint(equalTo: annualReturnTitle.leadingAnchor),
            annualReturnLabel.topAnchor.constraint(equalTo: annualReturnTitle.bottomAnchor, constant: 8)
        ])
    }
}
