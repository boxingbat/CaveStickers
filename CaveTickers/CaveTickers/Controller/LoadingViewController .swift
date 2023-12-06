//
//  LoadingViewController .swift
//  CaveTickers
//
//  Created by 1 on 2023/11/28.
//

import UIKit
import SwiftUI

// Base class that provides loading functionality
class LoadingViewController: UIViewController {
    private var loadingStateVC: UIHostingController<LoadingStateView>?
    override func viewDidLoad() {
        view.backgroundColor = .charcoalGray
    }

    // Method to show loading view
    func showLoadingView() {
        let loadingView = LoadingStateView(isLoading: true)
        loadingStateVC = UIHostingController(rootView: loadingView)
        guard let loadingStateVC = loadingStateVC else { return }

        addChild(loadingStateVC)
        loadingStateVC.view.frame = view.bounds
        view.addSubview(loadingStateVC.view)
        loadingStateVC.didMove(toParent: self)
    }

    // Method to hide loading view
    func hideLoadingView() {
        loadingStateVC?.willMove(toParent: nil)
        loadingStateVC?.view.removeFromSuperview()
        loadingStateVC?.removeFromParent()
        loadingStateVC = nil
    }
}
