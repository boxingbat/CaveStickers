//
//  CaculatorPresenter.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/20.
//
import UIKit
import SwiftUI

struct CalculatorPresenter {
    func getPresentation(result: DCAResult) -> CalculatorPresentation {
        let isProfitable = result.isProfitable == true
        let gainSymbol = isProfitable ? "+" : ""
        return .init(
            currentValueLabelBackgroundColor: isProfitable ? .themeGreenShade : .themeRedShade,
            currentValue: result.currentValue.currencyFormat,
            investmentAmount: result.investmentAmount.toCurrencyFormat(hasDecimalPlaces: false),
            gain: result.gain.toCurrencyFormat(
                hasDollarSymbol: true,
                hasDecimalPlaces: false
            )
            .prefix(withText: gainSymbol),
            yield: result.yield.percentageFormat,
            yieldLabelTextColor: isProfitable ? UIColor(Color.theme.green) : UIColor(Color.theme.red),
            annualReturn: result.annualReturn.percentageFormat,
            annualReturnLabelTextColor: isProfitable ? UIColor(Color.theme.green) : UIColor(Color.theme.red))
    }
}
struct CalculatorPresentation {
    let currentValueLabelBackgroundColor: UIColor
    let currentValue: String
    let investmentAmount: String
    let gain: String
    let yield: String
    let yieldLabelTextColor: UIColor
    let annualReturn: String
    let annualReturnLabelTextColor: UIColor
}
