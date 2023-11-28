//
//  WatchListTableViewCell.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/17.
//

import UIKit

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
        let changeColor: UIColor // red or green
        let companyName: String
        let changePercentage: String
    }
    // MARK: - Component
    /// Symbol Label
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.sfProDisplayMedium(size: 20)
        return label
    }()

    /// Company Label
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.sfProDisplayBold(size: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    /// Price Label
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.sfProDisplayBold(size: 18)
        label.textAlignment = .right
        return label
    }()

    /// Change Label
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()

    // MARK: - init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubview(symbolLabel)
        addSubview(nameLabel)
        addSubview(priceLabel)
        addSubview(changeLabel)
    }
    required init?(coder: NSCoder) {
        fatalError("error")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        symbolLabel.sizeToFit()
        nameLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()

        let yStart: CGFloat = (contentView.height - symbolLabel.height - nameLabel.height) / 2
        symbolLabel.frame = CGRect(
            x: separatorInset.left,
            y: yStart,
            width: symbolLabel.width,
            height: symbolLabel.height
        )

        nameLabel.frame = CGRect(
            x: separatorInset.left,
            y: symbolLabel.bottom,
            width: nameLabel.width,
            height: nameLabel.height
        )

        let currentWidth = max(
            max(priceLabel.width, changeLabel.width),
            WatchListViewController.maxChangeWidth
        )

        if currentWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWidth
            delegate?.didUpdatedMaxWith()
        }

        priceLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: (contentView.height - priceLabel.height - changeLabel.height) / 2,
            width: currentWidth,
            height: priceLabel.height
        )

        changeLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: priceLabel.bottom,
            width: currentWidth,
            height: changeLabel.height
        )
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
    }
}
