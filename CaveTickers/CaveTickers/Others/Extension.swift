//
//  Extension.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/16.
//

import Foundation
import UIKit

// MARK: - Frame

extension UIView {
    var width : CGFloat {
        frame.size.width
    }

    var height : CGFloat {
        frame.size.height
    }

    var left : CGFloat {
        frame.origin.x
    }

    var right : CGFloat {
        left + width
    }

    var top : CGFloat {
        frame.origin.y
    }

    var bottom : CGFloat {
        top + height
    }
}
