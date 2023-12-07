//
//  WalletViewController .swift
//  CaveTickers
//
//  Created by 1 on 2023/12/2.
//

import UIKit
import SwiftUI

class WalletViewController: LoadingViewController {
    var hostingController: UIHostingController<AnyView>?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHostingController()
    }

    func setupHostingController() {
        let manager = NFTDataManager()
            let swiftUIView = AnyView(
                NavigationView {
                    DashboardContentView().environmentObject(manager)
                }
            )
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
