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
    func didTapAddButton(_ headerView: StockDetailHeaderView)
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

    // MARK: - Init

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(label)
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("Error")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 14, y: 0, width: contentView.width - 28, height: contentView.height)

        button.sizeToFit()
        button.frame = CGRect(
            x: contentView.width - button.width - 16,
            y: (contentView.height - button.height) / 2,
            width: button.width + 8,
            height: button.height
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    /// Handle button tap
    @objc private func didTapButton() {
        // Call delegate
//        delegate?.newsHeaderViewDidTapAddButton(self)
    }

    /// Configure view
    /// - Parameter viewModel: View ViewModel
    public func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        label.font = UIFont.systemFont(ofSize: 20)
        button.isHidden = !viewModel.shouldShowAddButton
    }
}
