//
//  DetailHeaderView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/18.
//

import UIKit

final class StockDetailHeaderView: UIView,
                                   UICollectionViewDelegate,
                                   UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout {
    private var metricViewModels: [MetricCollectionViewCell.ViewModel] = []

    weak var delegate: DetailHeaderViewDelegate?
    public let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()

    /// CollectionView
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            MetricCollectionViewCell.self,
            forCellWithReuseIdentifier: MetricCollectionViewCell.identifier)
        collectionView.backgroundColor = .secondarySystemBackground
        return collectionView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
//        addSubview(chartView)
        addSubview(collectionView)
        addSubview(addButton)
//        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        collectionView.delegate = self
        collectionView.dataSource = self
//        chartView.backgroundColor = .systemBackground
    }

//    @objc private func didTapAddButton() {
//        delegate?.didTapAddButton(self)
//        }

    required init?(coder: NSCoder) {
        fatalError("Error")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = CGRect(x: 0, y: height - 100, width: width, height: 100)
        _ = CGSize(width: 80, height: 40)
    }
    func configure(
//        chartViewModel: StockChartView.ViewModel,
        metricViewModels: [MetricCollectionViewCell.ViewModel]
    ) {
//        chartView.configure(with: chartViewModel)
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
    }

    // MARK: - CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = metricViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MetricCollectionViewCell.identifier,
            for: indexPath
        ) as? MetricCollectionViewCell else {
            fatalError("Error")
        }
        cell.configure(with: viewModel)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: width / 2, height: 100 / 3)
    }
}
