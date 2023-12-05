//
//  Third-Party Ext.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/27.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(with url: String, placeholder: UIImage? = nil) {
        guard let url = URL(string: url) else {
            self.image = UIImage(named: "AppIcon")
            return
        }

        self.kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.2))]) { result in
            switch result {
            case .success(let value):
                print("Image set successfully: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Error setting image: \(error.localizedDescription)")
            }
        }
    }
}
