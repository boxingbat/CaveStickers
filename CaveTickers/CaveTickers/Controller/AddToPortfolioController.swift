//
//  AddToPortfolioController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/19.
//

import UIKit

class AddToPortfolioController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView = UITableView()
    var dataEntries :[String] = ["test"]
    let addButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        setupAddButton()

    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.register(AddPortfolioTableViewCell.self, forCellReuseIdentifier: "CustomCell")
    }

    private func setupAddButton() {
        addButton.setTitle("+", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        addButton.addTarget(self, action: #selector(addNewCell), for: .touchUpInside)
    }

    @objc private func addNewCell() {
        dataEntries.append("") // 添加一个新的数据项
        let indexPath = IndexPath(row: dataEntries.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataEntries.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < dataEntries.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! AddPortfolioTableViewCell
//            cell.configureWithData(data: dataEntries[indexPath.row])
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "SearchCell")
            let textField = UITextField(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height))
            textField.placeholder = "Search..."
            cell.contentView.addSubview(textField)
            return cell
        }
    }

    // MARK: - Navigation
}
