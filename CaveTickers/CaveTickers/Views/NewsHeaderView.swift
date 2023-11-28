//
//  NewsHeaderView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/18.
//
import UIKit

/// Delegate to notify of header evnets
protocol DetailHeaderViewDelegate: AnyObject {
    /// Notify user tapped header button
    /// - Parameter headerView: Ref of header view
    func didTapAddButton(_ headerView: NewsHeaderView)
//    func updatePriceLabel(price: String)
}

/// TableView header for news
final class NewsHeaderView: UITableViewHeaderFooterView {
    /// Header identifier
    static let identifier = "NewsHeaderView"
    /// Ideal height of header
    static let preferredHeight: CGFloat = 70

    /// Delegate instance for evnets
    weak var delegate: DetailHeaderViewDelegate?

    /// ViewModel for header view
    struct ViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }

    // MARK: - Private

    private let label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()

    let button: UIButton = {
        let button = UIButton()
        button.setTitle("+ Watchlist", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 8)
        button.backgroundColor = .themeGreenShade
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()

    var priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Closed"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    // MARK: - Init

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        addSubviews()
        setupConstraints()
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePriceLabel),
            name: NSNotification.Name("UpdatePriceLabel"),
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("Error")
    }
    @objc private func updatePriceLabel(notification: Notification) {
        if let price = notification.userInfo?["price"] as? String {
            self.priceLabel.text = price
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

        // MARK: - Setup

        private func addSubviews() {
            contentView.addSubview(label)
            contentView.addSubview(button)
            contentView.addSubview(priceLabel)
        }

        private func setupConstraints() {
            label.translatesAutoresizingMaskIntoConstraints = false
            button.translatesAutoresizingMaskIntoConstraints = false
            priceLabel.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                // Label Constraints
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                // Button Constraints
                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                // Price Label Constraints
                priceLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
                priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.leadingAnchor, constant: -8)
            ])
        }
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    /// Handle button tap
    @objc private func didTapButton() {
        delegate?.didTapAddButton(self)
    }

    /// Configure view
    /// - Parameter viewModel: View ViewModel
    public func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        label.font = UIFont.systemFont(ofSize: 20)
        button.isHidden = !viewModel.shouldShowAddButton
    }
}
