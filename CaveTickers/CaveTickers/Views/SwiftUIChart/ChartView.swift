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
    @ObservedObject var viewModel: ChartViewModel

    var body: some View {
        chart
            .chartXAxis { chartXAxis }
            .chartXScale(domain: data.xAxisData.axisStart...data.xAxisData.axisEnd)
        //            .chartYAxis { chartYAxis }
            .chartYScale(domain: data.yAxisData.axisStart...data.yAxisData.axisEnd)
            .chartPlotStyle { chartPlotStyle($0) }
            .chartOverlay { proxy in
                GeometryReader { gProxy in
                    Rectangle().fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { onChangeDrag(value: $0, chartProxy: proxy, geometryProxy: gProxy) }
                            .onEnded { _ in
                                viewModel.selectedX = nil
                            }
                        )
                }
            }
    }

    private var chart: some View {
        Chart {
            ForEach(Array(zip(data.items.indices, data.items)), id: \.0) { index, item in
                LineMark(
                    x: .value("Time", index),
                    y: .value("Price", item.value)
                ).foregroundStyle(viewModel.foregroundMarkColor)

                AreaMark(
                    x: .value("Time", index),
                    yStart: .value("Min", data.yAxisData.axisStart),
                    yEnd: .value("Max", item.value)
                )
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [
                        viewModel.foregroundMarkColor,
                        .clear
                ]), startPoint: .top,
                    endPoint: .bottom)
                )
                .opacity(0.3)

                if let previousClose = data.previousCloseRuleMarkValue {
                    RuleMark(y: .value("Previous Close", previousClose))
                        .lineStyle(.init(lineWidth: 0.1, dash: [2]))
                        .foregroundStyle(.gray.opacity(0.3))

                }

                if let (selectedX, text) = viewModel.selectedXRuleMark {
                    RuleMark(x: .value("Selected timestamp", selectedX))
                        .lineStyle(.init(lineWidth: 1))
                        .annotation {
                            Text(text)
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                        .foregroundStyle(viewModel.foregroundMarkColor)
                }

            }
        }
    }
    private var chartXAxis: some AxisContent {
        AxisMarks(values: .stride(by: data.xAxisData.strideBy)) { value in
            if let text = data.xAxisData.map[String(value.index)] {
                AxisGridLine(stroke: .init(lineWidth: 0.3))
                AxisTick(stroke: .init(lineWidth: 0.3))
                AxisValueLabel(collisionResolution: .greedy()) {
                    Text(text)
                        .foregroundColor(Color(uiColor: .label))
                        .font(.caption.bold())
                }
            }


        }
    }
    private var chartYAxis: some AxisContent {
        AxisMarks(preset: .extended, values: .stride(by: data.yAxisData.strideBy)) { value in
            if let yValue = value.as(Double.self),
            let text = data.yAxisData.map[yValue.roundedString] {
                AxisGridLine(stroke: .init(lineWidth: 0.3))
                AxisTick(stroke: .init(lineWidth: 0.3))
                AxisValueLabel(anchor: .topLeading, collisionResolution: .greedy) {
                    Text(text)
                        .foregroundColor(Color(uiColor: .label))
                        .font(.caption.bold())
                }
            }
        }
    }
    private func chartPlotStyle(_ plotContent: ChartPlotContent) -> some View {
        plotContent
            .frame(height: 200)
            .overlay {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.5))
                    .mask(ZStack {
                        VStack {
                            Spacer()
                            Rectangle().frame(height: 1)
                        }

                        HStack {
                            Spacer()
                            Rectangle().frame(width: 0.3)
                        }
                    })
            }
    }
    private func onChangeDrag(value: DragGesture.Value, chartProxy: ChartProxy, geometryProxy: GeometryProxy) {
        let xCurrent = value.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x
        if let index: Double = chartProxy.value(atX: xCurrent),
        index >= 0,
        Int(index) <= data.items.count - 1 {
            self.viewModel.selectedX = Int(index)
        }
    }

}

struct ChartView_Previews: PreviewProvider {

    static let allRanges = ChartRange.allCases
    static let oneDayOngoing = ChartData.stub1DOngoing

    static var previews: some View {
        ForEach(allRanges) {
            ChartContainer_ViewPreviews(viewModel: chartViewModel(range: $0, stub: $0.stubs), title: $0.title)
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
struct ChartContainer_ViewPreviews: View {

    @StateObject var viewModel: ChartViewModel
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .padding(.bottom)
            if let chartViewData = viewModel.chart {
                ChartView(data: chartViewData, viewModel: viewModel)
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
