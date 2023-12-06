//
//  MiniChartView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/28.
//

import XCAStocksAPI
import SwiftUI
import Charts

struct MiniChartView: View {
    let data: ChartViewData
    @ObservedObject var viewModel: ChartViewModel
    var body: some View {
        Chart(data.items, id: \.id) { item in
            LineMark(
                x: .value("Time", item.timestamp),
                y: .value("Price", item.value)
            )
            .foregroundStyle(viewModel.foregroundMarkColor)
        }
.frame(height: 200) 
    }
}
struct MiniChartView_Previews: PreviewProvider {
    static let allRanges = ChartRange.allCases
    static let oneDayOngoing = ChartData.stub1DOngoing

    static var previews: some View {
        ForEach(allRanges, id: \.self) { range in
            ChartContainer_ViewPreviews(viewModel: chartViewModel(range: range, stub: range.stubs), title: range.title)
        }
        ChartContainer_ViewPreviews(viewModel: chartViewModel(range: .oneDay, stub: oneDayOngoing), title: "1D Ongoing")
    }

    static func chartViewModel(range: ChartRange, stub: ChartData) -> ChartViewModel {
        var mockStocksAPI = MockStocksAPI()
        mockStocksAPI.stubbedFetchChartDataCallback = { _ in stub }
        let chartVM = ChartViewModel(ticker: .stub, apiService: mockStocksAPI)
        chartVM.selectedRange = range
        return chartVM
    }
}

// swiftlint:disable all
#if DEBUG
struct MiniChartContainer_ViewPreviews: View {
    @StateObject var viewModel: ChartViewModel
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .padding(.bottom)
            if let chartViewData = viewModel.chart {
                MiniChartView(data: chartViewData, viewModel: viewModel)
            }
        }
        .padding()
        .frame(maxHeight: 272)
        .previewLayout(.sizeThatFits)
        .previewDisplayName(title)
        .task { await viewModel.fetchData() }
    }
}
#endif
// swiftlint:enable all
