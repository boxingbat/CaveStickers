//
//  WatchListTableViewCell.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/17.
//

import UIKit
import Kingfisher

protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdatedMaxWith()
}

class WatchListTableViewCell: UITableViewCell {
    static let identifier = "WatchListTableViewCell"

    static let preferredHight: CGFloat = 60

    weak var delegate: WatchListTableViewCellDelegate?

    struct ViewModel {
        let symbol: String
        let price: String
        let changeColor: UIColor
        let companyName: String
        let changePercentage: String
        let marketCaptital: String
        let shareOutstanding: String
    }
    // MARK: - Component
    /// Symbol Label
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()

    /// Company Label
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    /// Price Label
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .right
        return label
    }()

    /// Change Label
    private let changeLabel: PaddedLabel = {
        let label = PaddedLabel()
        label.textAlignment = .right
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 4
        label.leftInset = 2
        label.rightInset = 2
        return label
    }()

    private let marketCap: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .right
        return label
    }()

    private let sharesOutstanding: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .right
        return label
    }()


    // MARK: - init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.clipsToBounds = true
            setupSubviews()
            setupConstraints()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    private func setupSubviews() {
            // Add subviews
            contentView.addSubview(symbolLabel)
            contentView.addSubview(nameLabel)
            contentView.addSubview(priceLabel)
            contentView.addSubview(changeLabel)
            contentView.addSubview(marketCap)
            contentView.addSubview(sharesOutstanding)

            // Set translatesAutoresizingMaskIntoConstraints to false
            symbolLabel.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            priceLabel.translatesAutoresizingMaskIntoConstraints = false
            changeLabel.translatesAutoresizingMaskIntoConstraints = false
            marketCap.translatesAutoresizingMaskIntoConstraints = false
            sharesOutstanding.translatesAutoresizingMaskIntoConstraints = false
        }

    private func setupConstraints() {
            // Define and activate constraints
            NSLayoutConstraint.activate([
                // Image View Constraints

                symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
                symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),

                // Name Label Constraints
                nameLabel.leadingAnchor.constraint(equalTo: symbolLabel.leadingAnchor),
                nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 5),

                // Price Label Constraints
                priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

                // Change Label Constraints
                changeLabel.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
                changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5),

                // Market Cap Label Constraints
                marketCap.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 60),
                marketCap.centerYAnchor.constraint(equalTo: symbolLabel.centerYAnchor),

                // Shares Outstanding Label Constraints
                sharesOutstanding.trailingAnchor.constraint(equalTo: marketCap.trailingAnchor),
                sharesOutstanding.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor)
            ])
        }
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
    }
    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        marketCap.text = viewModel.marketCaptital
        sharesOutstanding.text = viewModel.shareOutstanding
    }
}
