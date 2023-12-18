//
//  NewsTableViewCell.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/27.
//

import UIKit
import Kingfisher

/// News story tableView Cell
final class NewsTableViewCell: UITableViewCell {
    /// Cell id
    static let identfier = "NewsTableViewCell"

    /// Ideal height of cell
    static let preferredHeight: CGFloat = 140
    var viewModel: NewsModel? {
        didSet {
            bindViewModel()
        }
    }

    /// Source label
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    /// Headline label
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    /// Date label
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()

    /// Image for story
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
        addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("Init Error")
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        let imageSize: CGFloat = contentView.height / 1.4
        storyImageView.frame = CGRect(
            x: contentView.width - imageSize - 10,
            y: (contentView.height - imageSize) / 2,
            width: imageSize,
            height: imageSize
        )

        // Layout labels
        let availableWidth: CGFloat = contentView.width - separatorInset.left - imageSize - 15
        dateLabel.frame = CGRect(
            x: separatorInset.left,
            y: contentView.height - 40,
            width: availableWidth,
            height: 40
        )

        sourceLabel.sizeToFit()
        sourceLabel.frame = CGRect(
            x: separatorInset.left,
            y: 4,
            width: availableWidth,
            height: sourceLabel.height
        )

        headlineLabel.frame = CGRect(
            x: separatorInset.left,
            y: sourceLabel.bottom + 5,
            width: availableWidth,
            height: contentView.height - sourceLabel.bottom - dateLabel.height - 10
        )
    }
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        let date = Date(timeIntervalSince1970: viewModel.datetime)
        dateLabel.text = DateFormatter.prettyDateFormatter.string(from: date)
        storyImageView.setImage(with: viewModel.image, placeholder: UIImage(named: "APPIcon")
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }
}
