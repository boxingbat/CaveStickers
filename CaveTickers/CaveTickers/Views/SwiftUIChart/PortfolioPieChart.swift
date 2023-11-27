//
//  PortfolioPieChart.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/26.
//

import SwiftUI

struct PortfolioPieChart: View {
    @ObservedObject var viewModel: PieChartViewModel
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<viewModel.pieChartSegments.count, id: \.self) { index in
                    self.sliceView(geometry: geometry, index: index)
                        .padding(2)
                }
                Circle()
                    .fill(Color(UIColor.systemBackground))
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.6)
                VStack {
                    Text("Invested")
                        .font(.headline)
                    Text("$\(viewModel.totalInvestmentAmount, specifier: "%.2f")")
                        .font(.caption)
                    Text("Current")
                        .font(.headline)
                    Text("$\(viewModel.totalCurrentValue, specifier: "%.2f")")
                        .font(.caption)
                    Text("Growth")
                        .font(.headline)
                    Text("\(viewModel.growthRate, specifier: "%.2f")%")
                        .font(.caption)
                }
            }
        }
    }
    private func sliceView(geometry: GeometryProxy, index: Int) -> some View {
        let segment = viewModel.pieChartSegments[index]
        let angle = 360 * segment.percentage / 100
        let startAngleDegrees = viewModel.pieChartSegments[0..<index].reduce(0) { $0 + ($1.percentage / 100 * 360) }
        let endAngleDegrees = startAngleDegrees + angle

        return PieSlice(startAngle: .degrees(startAngleDegrees), endAngle: .degrees(endAngleDegrees))
            .fill(self.color(for: segment))
            .overlay(sliceLabel(geometry: geometry, segment: segment, startAngle: .degrees(startAngleDegrees), endAngle: .degrees(endAngleDegrees)))
    }

    private func sliceLabel(geometry: GeometryProxy, segment: PieChartSegment, startAngle: Angle, endAngle: Angle) -> some View {
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

        let radius = min(geometry.size.width, geometry.size.height) / 2.5
        let midAngle = Angle(degrees: (startAngle.degrees + endAngle.degrees) / 2)
        let xOffset = cos(midAngle.radians) * radius
        let yOffset = sin(midAngle.radians) * radius
        let labelPosition = CGPoint(
            x: center.x + xOffset,
            y: center.y + yOffset
        )
        return Text(segment.symbol)
            .position(labelPosition)
            .font(.caption)
    }
    private func color(for segment: PieChartSegment) -> Color {
        return Color(hue: Double.random(in: 0...1), saturation: 0.8, brightness: 0.5)
    }
}

struct PortfolioPieChart_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PieChartViewModel()
        viewModel.pieChartSegments = [
            PieChartSegment(symbol: "AAPL", value: 50, percentage: 50),
            PieChartSegment(symbol: "MSFT", value: 30, percentage: 30),
            PieChartSegment(symbol: "GOOGL", value: 20, percentage: 20)
        ]
        return PortfolioPieChart(viewModel: viewModel)
            .frame(width: 300, height: 300)
    }
}

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}
