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
            }
            .edgesIgnoringSafeArea(.all)
        }
    }

struct LoadingStateView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingStateView(isLoading: true)
    }
}
