//
//  DateTableViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/20.
//

import UIKit

class DateTableViewController: UITableViewController {
    var timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted?
    var selectedIndex: Int?
    private var monthInfos: [MonthInfo] = []

    var didSelectDate: ((Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMonthInfos()
        setupNavigation()
        tableView.register(DateSelectionTableViewCell.self, forCellReuseIdentifier: "cellId")
    }

    private func setupNavigation() {
        title = "Select date"
    }

    private func setupMonthInfos() {
        monthInfos = timeSeriesMonthlyAdjusted?.getMonthInfos() ?? []
    }
}

extension DateTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthInfos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable all
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DateSelectionTableViewCell
        // swiftlint:enable all
        let index = indexPath.item
        let monthInfo = monthInfos[index]
        let isSelected = index == selectedIndex
        cell.configure(with: monthInfo, index: index, isSelected: isSelected)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectDate?(indexPath.item)
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
    }
}
class DateSelectionTableViewCell: UITableViewCell {
    let monthLabel = UILabel()
    let monthsAgoLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(monthLabel)
            contentView.addSubview(monthsAgoLabel)

            monthLabel.translatesAutoresizingMaskIntoConstraints = false
            monthsAgoLabel.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                monthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
                monthLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

                monthsAgoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
                monthsAgoLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    func configure(with monthInfo: MonthInfo, index: Int, isSelected: Bool) {
        monthLabel.text = monthInfo.date.MMYYFormat
        accessoryType = isSelected ? .checkmark : .none
        if index == 1 {
            monthsAgoLabel.text = "1 month ago"
        } else if index > 1 {
            monthsAgoLabel.text = "\(index) months ago"
        } else {
            monthsAgoLabel.text = "Just invested"
        }
    }
}
