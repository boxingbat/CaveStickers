//
//  UIApplication.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/30.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
