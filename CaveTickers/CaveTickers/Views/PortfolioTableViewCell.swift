//
//  PortfolioTableViewCell.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/19.
//

import UIKit

class StockTableViewCell: UITableViewCell {

    let stockInfoLabel = UILabel()
    let changeRateLabel = UILabel()

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
        changeRateLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stockInfoLabel)
        addSubview(changeRateLabel)

        NSLayoutConstraint.activate([
            stockInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stockInfoLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            changeRateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            changeRateLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
