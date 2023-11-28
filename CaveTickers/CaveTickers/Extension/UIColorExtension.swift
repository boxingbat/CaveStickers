//
//  UIColorExtension.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/20.
//
import UIKit

extension UIColor {

    static let themeRedShade = UIColor(hex: "fae2e1")
    static let themeGreenShade = UIColor(hex: "b0f1dd")

    // Emerald Garden
    static let coolMint = UIColor(hex: "9BCFB8")
    static let succulent = UIColor(hex: "7FB174")
    static let juniper = UIColor(hex: "689C97")
    static let brunswick = UIColor(hex: "072A24")
    // Celestial Green
    static let taupe = UIColor(hex: "B2A59F")
    static let spaceBlue = UIColor(hex: "023459")
    static let caribbean = UIColor(hex: "1E646E")
    static let peacock = UIColor(hex: "002C2F")
    // Northern Lights
    static let mermudaGreen = UIColor(hex: "B2A59F")
    static let springGreen = UIColor(hex: "023459")
    static let aegeanBlue = UIColor(hex: "1E646E")
    static let nightSky = UIColor(hex: "002C2F")
    static let nightFall = UIColor(hex: "324856")
    static let gloomyNavy = UIColor(hex: "030923")
    static let charcoalGray = UIColor(hex: "353C42")
    // Sea Green
    static let summgerGreen = UIColor(hex: "97BAA4")
    static let jadeGreen = UIColor(hex: "499360")
    static let deepPineGreen = UIColor(hex: "295651")
    static let whaleBlue = UIColor(hex: "232941")
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") { cString.removeFirst() }

        if (cString.count) != 6 {
            self.init(hex: "ff0000") // return red color for wrong hex input
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha)
    }
}
