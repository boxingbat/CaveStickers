//
//  NewsViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import Kingfisher
import SafariServices
import UIKit

class NewsViewController: LoadingViewController {
    private var news: [NewsStory] = []
    var headerTitle: String?

    let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identfier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTableView()
        showLoadingView()
        fetchNews()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    // MARK: - Private fcuntion
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
}

    private func fetchNews() {
        let group = DispatchGroup()
        group.enter()
        APIManager.shared.news { [weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let news):
                DispatchQueue.main.async {
                    self?.news = news
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) {[weak self] in
            self?.hideLoadingView()
        }
    }
    private func open(url: URL) {
        let SFvc = SFSafariViewController(url: url)
        present(SFvc, animated: true)
    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identfier,
            for: indexPath
        )as? NewsTableViewCell else {
            fatalError("cell connected failed")
        }
        cell.configure(with: .init(model: news[indexPath.row]))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsTableViewCell.preferredHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        HapticsManager.shared.vibrateForSelection()

        // Open news story
        let story = news[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFailedToOpenAlert()
            return
        }
        open(url: url)
    }

    /// Present an alert to show an error occurred when opening story
    private func presentFailedToOpenAlert() {
        HapticsManager.shared.vibrate(for: .error)

        let alert = UIAlertController(
            title: "Unable to Open",
            message: "We were unable to open the article.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
