//
//  ChartView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/1.
//

import SwiftUI

struct CryptoChartView: View {
    private let data: [Double]
    private let maxY: Double
    private let minY: Double
    private var lineColor: Color
    private let stratingDate: Date
    private let endingDate: Date
    @State private var percentage: CGFloat = 0
    @State private var touchLocation: CGPoint = .zero
    @State private var showPopover = false
    @State private var showPulsatingView = false


    init(coin: CoinModel) {
        data = coin.sparklineIn7D?.price ?? []
        maxY = data.max() ?? 0
        minY = data.min() ?? 0

        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        lineColor = priceChange > 0 ? Color.theme.green : Color.theme.red

        endingDate = Date(coinGeckoString: coin.lastUpdated ?? "")
        stratingDate = endingDate.addingTimeInterval(-7 * 24 * 60 * 60)
    }

    var body: some View {
        VStack {
            chartView
                .frame(height: 200)
                .background(chartBackground)
                .overlay(chartYAxis.padding(.horizontal, 4), alignment: .trailing)
            chartDataLabel
                .padding(.horizontal, 4)
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.linear(duration: 2.0)) {
                    percentage = 1.0
                }
            }
        }
    }
}

struct CryptoChartView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoChartView(coin: dev.coin)
    }
}

struct PopoverView: View {
    @Binding var show: Bool
    let touchPoint: CGPoint
    let chartData: [Double]
    let maxY: Double
    let minY: Double
    let frame: CGRect
    let lineColor: Color

    var body: some View {
        let touchIndex = min(max(Int((touchPoint.x / frame.width) * CGFloat(chartData.count)), 0), chartData.count - 1)
        let touchedData = chartData[touchIndex]
        let displayValue = touchedData

        return Group {
            if show {
                Text("\(displayValue)")
                    .font(.caption)
                    .padding(5)
                    .background(lineColor.opacity(0.7))
                    .cornerRadius(5)
                    .foregroundColor(.white)
                    .offset(x: calculateOffsetX(touchIndex: touchIndex, frame: frame), y: calculateOffsetY(frame: frame))
                    .transition(.scale)
            }
        }
    }
    private func calculateOffsetX(touchIndex: Int, frame: CGRect) -> CGFloat {
        let xPosition = frame.width / CGFloat(chartData.count) * CGFloat(touchIndex + 1)
        if xPosition > frame.midX {
            return touchPoint.x - 200
        } else {
            return touchPoint.x - 150
        }
    }

    private func calculateOffsetY(frame: CGRect) -> CGFloat {
        if touchPoint.y < frame.midY {
            return touchPoint.y
        } else {
            return touchPoint.y - 180
        }
    }
}


extension CryptoChartView {
    private var chartView: some View {
        GeometryReader { geometry in
            ZStack {
                // 创建一个路径用于绘制线图
                Path { path in
                    for index in data.indices {
                        let xPosition = geometry.size.width / CGFloat(data.count) * CGFloat(index + 1)
                        let yAxis = maxY - minY
                        let yPosition = (1 - CGFloat((data[index] - minY) / yAxis)) * geometry.size.height

                        if index == 0 {
                            path.move(to: CGPoint(x: xPosition, y: yPosition))
                        } else {
                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                        }
                    }
                }
                .trim(from: 0, to: percentage)
                .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .shadow(color: lineColor, radius: 10, x: 0.0, y: 10)
                .shadow(color: lineColor.opacity(0.5), radius: 10, x: 0.0, y: 20)
                .contentShape(Rectangle())
                .gesture(DragGesture().onChanged { value in
                    touchLocation = value.location
                    showPopover = true
                }
                .onEnded { _ in
                    showPopover = false
                })
                if showPulsatingView, let lastData = data.last {
                            let xPosition = geometry.size.width / CGFloat(data.count) * CGFloat(data.count - 1)
                            let yAxis = maxY - minY
                            let yPosition = (1 - CGFloat((lastData - minY) / yAxis)) * geometry.size.height

                            PulsatingView(color: lineColor)
                                .position(x: xPosition, y: yPosition)
                                .zIndex(1) 
                        }
                    }
            .overlay(
                PopoverView(
                    show: $showPopover,
                    touchPoint: touchLocation,
                    chartData: data,
                    maxY: maxY,
                    minY: minY,
                    frame: geometry.frame(in: .local),
                    lineColor: lineColor
                )
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeOut(duration: 1.0)) {
                                self.showPulsatingView = true
                            }
                        }
                    }
        }
    }

    private var chartBackground: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }
    private var chartYAxis: some View {
        VStack {
            Text(maxY.formatUsingAbbrevation())
            Spacer()
            Text(((maxY + minY) / 2).formatUsingAbbrevation())
            Spacer()
            Text(minY.formattedWithAbbreviations())
        }
    }

    private var chartDataLabel: some View {
        HStack {
            Text(stratingDate.asShortDateString())
            Spacer()
            Text(endingDate.asShortDateString())
        }
    }
}
