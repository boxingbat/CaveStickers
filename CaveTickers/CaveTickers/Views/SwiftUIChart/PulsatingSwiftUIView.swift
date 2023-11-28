//
//  PulsatingSwiftUIView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/28.
//

import SwiftUI

struct PulsatingView: View {
    @State private var pulsate = false
    var color: Color // 使用 SwiftUI 的 Color 类型

    var body: some View {
        Circle()
            .fill(color.opacity(0.5)) // 使用传入的颜色
            .frame(width: 10, height: 10)
            .scaleEffect(pulsate ? 1.5 : 1)
            .opacity(pulsate ? 0 : 1)
            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false), value: pulsate)
            .onAppear {
                self.pulsate.toggle()
            }
    }
}

struct PulsatingView_Previews: PreviewProvider {
    static var previews: some View {
        PulsatingView(color: .purple)
    }
}
