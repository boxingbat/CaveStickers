//
//  CircleButtonView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/29.
//

import SwiftUI

struct CircleButtonView: View {
    let iconName: String

    var body: some View {
        Image(systemName: "\(iconName)")
            .font(.headline)
            .foregroundColor(Color.theme.accent)
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .foregroundColor(Color(UIColor.systemBackground))
            )
            .shadow(
                color: Color.theme.accent.opacity(0.3),
            radius: 10,
                x: 0,
                y: 0
            )
            .padding()
    }
}

struct CircleButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CircleButtonView(iconName: "info")
            .previewLayout(.sizeThatFits)
    }
}
