//
//  SearchViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import UIKit

protocol SearchTableViewDelegate: AnyObject {
    func searchViewControllerDidSelect(searchResult: SearchResult)
}

class SearchViewController: UIViewController {
    weak var delegate: SearchTableViewDelegate?

    private var results: [SearchResult] = []

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        setUpTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }

    public func update(with result: [SearchResult]) {
        self.results = result
        tableView.isHidden = result.isEmpty
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath)

        let data = results[indexPath.row]

        cell.textLabel?.text = data.displaySymbol
        cell.detailTextLabel?.text = data.description

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = results[indexPath.row]
        delegate?.searchViewControllerDidSelect(searchResult: data)
    }
}
