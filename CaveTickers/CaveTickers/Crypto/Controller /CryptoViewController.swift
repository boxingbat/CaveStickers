//
//  CryptoViewController.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/15.
//

import UIKit
import SwiftUI

class CryptoViewController: LoadingViewController {
@ObservedObject var viewModel = HomeViewModel()
    var hostingController: UIHostingController<AnyView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHostingController()
    }

    func setupHostingController() {
        let swiftUIView = AnyView(CryptoHomePageView(viewModel: self.viewModel)
            .environmentObject(viewModel))
        hostingController = UIHostingController(rootView: swiftUIView)

        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}
