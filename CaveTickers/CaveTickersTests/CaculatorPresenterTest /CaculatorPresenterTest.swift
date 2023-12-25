//
//  CaculatorPresenterTest.swift
//  CaveTickersTests
//
//  Created by 1 on 2023/12/25.
//

import XCTest
@testable import CaveTickers
import SwiftUI

final class CaculatorPresenterTest: XCTestCase {
    var presenter = CalculatorPresenter()
    func testGetPresentationForProfitableResult() {
        let profitableResult = DCAResult(
            currentValue: 1200,
            investmentAmount: 1000.00,
            gain: 200.00,
            yield: 0.2,
            annualReturn: 0.1,
            isProfitable: true
        )

        let presentation = presenter.getPresentation(result: profitableResult)

        XCTAssertEqual(presentation.currentValueLabelBackgroundColor, UIColor.themeGreenShade)
        XCTAssertEqual(presentation.currentValue, "$1,200.00")
        XCTAssertEqual(presentation.investmentAmount, "$1,000")
        XCTAssertEqual(presentation.gain, "+$200")
        XCTAssertEqual(presentation.yield, "20%")
        XCTAssertEqual(presentation.yieldLabelTextColor, UIColor(Color.themeGreen))
        XCTAssertEqual(presentation.annualReturn, "10%")
        XCTAssertEqual(presentation.annualReturnLabelTextColor, UIColor(Color.themeGreen))
    }

    func testGetPresentationForNonProfitableResult() {
        let nonProfitableResult = DCAResult(
            currentValue: 800,
            investmentAmount: 1000.00,
            gain: -200.00,
            yield: -0.20,
            annualReturn: -0.10,
            isProfitable: false
        )

        let presentation = presenter.getPresentation(result: nonProfitableResult)

        XCTAssertEqual(presentation.currentValueLabelBackgroundColor, UIColor.themeRedShade)
        XCTAssertEqual(presentation.currentValue, "$800.00")
        XCTAssertEqual(presentation.investmentAmount, "$1,000")
        XCTAssertEqual(presentation.gain, "-$200")
        XCTAssertEqual(presentation.yield, "-20%")
        XCTAssertEqual(presentation.yieldLabelTextColor, UIColor(Color.themeRed))
        XCTAssertEqual(presentation.annualReturn, "-10%")
        XCTAssertEqual(presentation.annualReturnLabelTextColor, UIColor(Color.themeRed))
    }
}
