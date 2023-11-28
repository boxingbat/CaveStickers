//
//  FontExtension.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/28.
//

import UIKit

extension UIFont {


    static func sfProDisplayThin(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .thin)
    }

    static func sfProDisplayLight(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .light)
    }

    static func sfProDisplayRegular(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func sfProDisplayMedium(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func sfProDisplaySemibold(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    static func sfProDisplayBold(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

    static func sfProDisplayHeavy(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .heavy)
    }

    static func sfProDisplayBlack(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .black)
    }

    // MARK: - San Francisco Text Styles
    static func sfProTextThin() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .body).withWeight(.thin)
    }

    static func sfProTextLight() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .body).withWeight(.light)
    }

    static func sfProTextRegular() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .body).withWeight(.regular)
    }

    static func sfProTextMedium() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .body).withWeight(.medium)
    }

    static func sfProTextSemibold() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .body).withWeight(.semibold)
    }

    static func sfProTextBold() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .body).withWeight(.bold)
    }

    static func sfProTextHeavy() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .body).withWeight(.heavy)
    }

    static func sfProTextBlack() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .body).withWeight(.black)
    }
}

// MARK: - Helper to apply weight to preferredFont
private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = self.fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: descriptor, size: 0) // size 0 means keep the size as it is in the descriptor
    }
}

