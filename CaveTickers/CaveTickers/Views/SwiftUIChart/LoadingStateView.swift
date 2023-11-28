//
//  LoadingStateView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//
import SwiftUI

struct LoadingStateView: View {

    @State private var isAnimating = false
    var isLoading: Bool

    var body: some View {
        Image("Logo_Circle") // Replace "coin" with your coin image asset name
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50) // Adjust the size as needed
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

struct LoadingStateView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingStateView(isLoading: true)
    }
}
