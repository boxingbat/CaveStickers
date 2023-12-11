//
//  LoadingStateView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//
import SwiftUI
import UIKit

struct LoadingStateView: View {
    @State private var isAnimating = false
    var isLoading: Bool

    var body: some View {
        VStack {
            Image("Logo_Circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }

            HStack(spacing: 0) {
                ForEach(Array("Loading...".enumerated()), id: \.offset) { index, letter in
                    JumpingText(text: String(letter), delay: Double(index) * 0.1)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct LoadingStateView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingStateView(isLoading: true)
    }
}

struct JumpingText: View {
    let text: String
    let delay: Double

    @State private var isAnimating = false

    var body: some View {
        Text(String(text))
            .font(.title)
            .foregroundColor(.theme.accent)
            .offset(y: isAnimating ? -5 : 5)
            .animation(
                Animation.easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
