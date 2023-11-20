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

        // 创建一个新的 UIView 作为表头视图，并设置背景色
        let headerView = UIView()
        headerView.backgroundColor = .link
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width - 32, height: 250) // 设置宽度减去左右边距，高度为 250

        // 设置表头视图
        tableView.tableHeaderView = headerView

        // 设置 tableView 的约束
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let addButton = UIButton(type: .custom)
          addButton.translatesAutoresizingMaskIntoConstraints = false
          addButton.backgroundColor = .blue // 可以自定义颜色
          addButton.setTitle("+", for: .normal)
          addButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
          addButton.layer.cornerRadius = 25 // 使按钮成圆形
          view.addSubview(addButton)

          // 设置按钮的约束
          NSLayoutConstraint.activate([
              addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
              addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
              addButton.widthAnchor.constraint(equalToConstant: 50),
              addButton.heightAnchor.constraint(equalToConstant: 50)
          ])

          // 配置按钮点击事件
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

// UITableViewDelegate, UITableViewDataSource 的扩展部分保持不变

extension PortfolioViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40 // Row height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockTableViewCell
        // Configure the cell...
        cell.stockInfoLabel.text = "Stock \(indexPath.row)" // Example stock info
        cell.changeRateLabel.text = "+/- Rate" // Example change rate
        return cell
    }
}
