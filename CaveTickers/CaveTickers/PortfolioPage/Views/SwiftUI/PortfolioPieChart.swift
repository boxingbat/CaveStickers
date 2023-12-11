//
//  PortfolioPieChart.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/26.
//

import SwiftUI

struct PortfolioPieChart: View {
    @ObservedObject var viewModel: PieChartViewModel
    @State private var isBreathing = false


    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    ForEach(0..<viewModel.pieChartSegments.count, id: \.self) { index in
                        self.sliceView(geometry: geometry, index: index)
                            .padding(2)
                    }
                    ForEach(0..<viewModel.pieChartSegments.count, id: \.self) { index in
                        self.labelView(geometry: geometry, index: index)
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                Spacer(minLength: 20)
                VStack(alignment: .leading) {
                    Text("Invested")
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)

                    Text("$\(viewModel.totalInvestmentAmount.toIntegerPartString())")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.accent)
                        .frame(height: 24)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current")
                            .font(.caption)
                            .foregroundColor(Color.theme.secondaryText)
                        Text("$\(viewModel.totalCurrentValue.toIntegerPartString())")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading) {
                        Text("Growth")
                            .font(.caption)
                            .foregroundColor(Color.theme.secondaryText)

                        Text("\(viewModel.growthRate, specifier: "%.2f")%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.growthRate >= 0 ? Color.theme.accent : .red)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
            }
            .padding(.top, 8)
        }
    }
    private func sliceView(geometry: GeometryProxy, index: Int) -> some View {
        let segment = viewModel.pieChartSegments[index]
        let angle = 360 * segment.percentage / 100
        let spacing: Double = 8
        let startAngleDegrees = viewModel.pieChartSegments[0..<index].reduce(0) {
            $0 + ($1.percentage / 100 * 360)
        } + spacing
        let endAngleDegrees = startAngleDegrees + angle - spacing

        return PieSlice(startAngle: .degrees(startAngleDegrees), endAngle: .degrees(endAngleDegrees))
            .fill(self.color(for: segment))
            .shadow(color: .theme.secondaryText.opacity(isBreathing ? 1 : 0.5), radius: isBreathing ? 3 : 2, x: 0, y: 2)
            .overlay(
                PieSlice(startAngle: .degrees(startAngleDegrees), endAngle: .degrees(endAngleDegrees))
                    .stroke(Color.black, lineWidth: 0.5)
            )
    }
    private func sliceLabel(
        geometry: GeometryProxy,
        segment: PieChartSegment,
        startAngle: Angle,
        endAngle: Angle
    ) -> some View {
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
    private func labelView(geometry: GeometryProxy, index: Int) -> some View {
        let segment = viewModel.pieChartSegments[index]
        let angle = 360 * segment.percentage / 100
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        let radius = geometry.size.width / 2

        let startAngleDegrees = viewModel.pieChartSegments.prefix(index).reduce(0) {
            $0 + (360 * $1.percentage / 100)
        }
        let endAngleDegrees = startAngleDegrees + angle
        let midAngle = (startAngleDegrees + endAngleDegrees) / 2 * (.pi / 180)

        let labelX = center.x - 50 + cos(midAngle) * radius * 0.5
        let labelY = center.y - 50 + sin(midAngle) * radius * 0.45

        return Text(segment.symbol)
            .position(x: labelX, y: labelY)
            .font(.headline)
            .foregroundColor(Color.theme.accent)
            .shadow(color: .black.opacity(0.1), radius: 1, x: 1, y: 1)
    }
}

struct PortfolioPieChart_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PieChartViewModel()
        viewModel.pieChartSegments = [
            PieChartSegment(symbol: "AAPL", value: 40, percentage: 40),
            PieChartSegment(symbol: "MSFT", value: 30, percentage: 30),
            PieChartSegment(symbol: "GOOG", value: 20, percentage: 20),
            PieChartSegment(symbol: "SE", value: 10, percentage: 10)
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
