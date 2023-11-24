//
//  ChartView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//

import SwiftUI
import XCAStocksAPI
import Charts


struct ChartView: View {
    let data: ChartViewData

    var body: some View {
        chart
    }

    private var chart: some View {
        Chart {
            ForEach(data.items) {
                LineMark(
                    x: .value("Time", $0.timestamp),
                    y: .value("Price", $0.value))
            }
        }
    }
}

struct ChartView_Previews: PreviewProvider {

    static let allRanges = ChartRange.allCases
    static let oneDayOngoing = ChartData.stub1DOngoing

    static var previews: some View {
        ForEach(allRanges) {
            ChartContainer_ViewPreviews(veiwModel: chartViewModel(range: $0, stub: $0.stubs), title: $0.title)
        }

        ChartContainer_ViewPreviews(veiwModel: chartViewModel(range: .oneDay, stub: oneDayOngoing), title: "1D Ongoing")

    }

    static func chartViewModel(range: ChartRange, stub: XCAStocksAPI.Chart) -> ChartViewModel {
        var mockStocksAPI = MockStocksAPI()
        mockStocksAPI.stubbedFetchChartDataCallback = { _ in stub }
        let chartVM = ChartViewModel(ticker: .stub, apiService: mockStocksAPI)
        chartVM.selectedRange = range
        return chartVM
    }

}

// swiftlint:disable all
#if DEBUG
struct ChartContainer_ViewPreviews: View {

    @StateObject var veiwModel: ChartViewModel
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .padding(.bottom)
            if let chartViewData = veiwModel.chart {
                ChartView(data: chartViewData)
            }
        }
        .padding()
        .frame(maxHeight: 272)
        .previewLayout(.sizeThatFits)
        .previewDisplayName(title)
        .task { await veiwModel.fetchData() }
    }

}

#endif
// swiftlint:enable all
