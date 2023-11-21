//
//  EventManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/16.
//

import Foundation
import UIKit

/// Object to manage haptics
final class TapManager {
    /// Singleton
    static let shared = TapManager()

    /// Private constructor
    private init() {}

    // MARK: - Public

    /// Vibrate slightly for selection
    public func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    /// Play haptic for given type interaction
    /// - Parameter type: Type to vibrate for
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
