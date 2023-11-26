//
//  DismissButton.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/25.
//

import Foundation
import UIKit
import SwiftUI

struct DismissButton: UIViewControllerRepresentable {
    var onDismiss: () -> Void

    func makeUIViewController(context: Context) -> some UIViewController {
        DismissButtonViewController(onDismiss: onDismiss)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    class DismissButtonViewController: UIViewController {
        var onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            if parent == nil { // The view controller was popped
                onDismiss()
            }
        }
    }
}

