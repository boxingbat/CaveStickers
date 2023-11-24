//
//  DateRangePickerView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//

import SwiftUI
import XCAStocksAPI

struct DateRangePickerView: View {
    let rangeType = ChartRange.allCases
    @Binding var selectedRange: ChartRange

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                ForEach(rangeType, id: \.self) { dateRange in
                    Button {
                        self.selectedRange = dateRange
                    } label: {
                        Text(dateRange.title)
                            .font(.callout.bold())
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .background(backgroundView(for: dateRange))
                }
            }.padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }

    private func backgroundView(for range: ChartRange) -> some View {
        RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
            .fill(range == selectedRange ? Color.gray.opacity(0.4) : Color.clear)
    }
}


struct DateRangePickerView_Previews: PreviewProvider {

    @State static var dateRange = ChartRange.oneDay

    static var previews: some View {
        DateRangePickerView(selectedRange: $dateRange)
            .padding(.vertical)
            .previewLayout(.sizeThatFits)
    }
}
