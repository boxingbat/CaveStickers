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
    let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        setupSaveButton()
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
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
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
        dataEntries.append("")
        let indexPath = IndexPath(row: dataEntries.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    private func setupSaveButton() {
            saveButton.setTitle("Save", for: .normal)
            saveButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(saveButton)

            NSLayoutConstraint.activate([
                saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                saveButton.heightAnchor.constraint(equalToConstant: 50)
            ])

            saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        }

        @objc private func saveButtonTapped() {
            // Handle the save action
        }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataEntries.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < dataEntries.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! AddPortfolioTableViewCell
//            cell.configureWithData(data: dataEntries[indexPath.row])
            cell.TimeLineInputTextField.delegate = self

            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "SearchCell")
            let textField = UITextField(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height))
            textField.placeholder = "...Add More Stock"
            cell.contentView.addSubview(textField)
            return cell
        }
    }

    // MARK: - Navigation
}

extension AddToPortfolioController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let cell = textField.superview?.superview as? AddPortfolioTableViewCell,
           textField == cell.TimeLineInputTextField {
            let DateTableViewController = DateTableViewController()
            navigationController?.pushViewController(DateTableViewController, animated: true)
            return false
        }
        return true
    }
}
