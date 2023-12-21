//
//  TableSectionHeaderView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/17.
//

import Foundation
import UIKit

class TableSectionHeaderView: UIView {
    private let stockLabel = UILabel()
    private let marketCapLabel = UILabel()
    private let priceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stockLabel)
        addSubview(marketCapLabel)
        addSubview(priceLabel)

        stockLabel.text = "Stock"
        marketCapLabel.text = "MarketCap"
        priceLabel.text = "Price"

        stockLabel.textColor = .gray
        marketCapLabel.textColor = .gray
        priceLabel.textColor = .gray

        stockLabel.font = .systemFont(ofSize: 12)
        marketCapLabel.font = .systemFont(ofSize: 12)
        priceLabel.font = .systemFont(ofSize: 12)

        stockLabel.translatesAutoresizingMaskIntoConstraints = false
        marketCapLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stockLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stockLabel.topAnchor.constraint(equalTo: topAnchor),
            stockLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            marketCapLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 30),
            marketCapLabel.topAnchor.constraint(equalTo: topAnchor),
            marketCapLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            priceLabel.topAnchor.constraint(equalTo: topAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
