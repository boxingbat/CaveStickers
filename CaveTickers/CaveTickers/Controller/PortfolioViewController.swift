//
//  PortfolioViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import UIKit

class PortfolioViewController: UIViewController {

    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)


        let headerView = UIView()
        headerView.backgroundColor = .link
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width - 32, height: 250)


        tableView.tableHeaderView = headerView

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let addButton = UIButton(type: .custom)
          addButton.translatesAutoresizingMaskIntoConstraints = false
          addButton.backgroundColor = .blue
          addButton.setTitle("+", for: .normal)
          addButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
          addButton.layer.cornerRadius = 25
          view.addSubview(addButton)

          // 设置按钮的约束
          NSLayoutConstraint.activate([
              addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
              addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
              addButton.widthAnchor.constraint(equalToConstant: 50),
              addButton.heightAnchor.constraint(equalToConstant: 50)
          ])

          addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        tableView.register(StockTableViewCell.self, forCellReuseIdentifier: "StockCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc private func addButtonTapped() {
        let addPortfolioVC = AddToPortfolioController()
        navigationController?.pushViewController(addPortfolioVC, animated: true)
    }
    // MARK: - Navigation

}


extension PortfolioViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40 
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockTableViewCell
        cell.stockInfoLabel.text = "GOOG"
        cell.changeRateLabel.text = "+ 2.6%"
        cell.changeRateLabel.textColor = .systemGreen
        return cell
    }
}
