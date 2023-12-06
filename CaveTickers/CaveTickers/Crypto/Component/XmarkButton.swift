//
//  XmarkButton.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/30.
//

import SwiftUI

struct XmarkButton: View {
    @Environment(
        \.presentationMode
    )
    var presentationMode
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "xmark")
                .font(.headline)
        })
    }
}

#Preview {
    XmarkButton()
}
