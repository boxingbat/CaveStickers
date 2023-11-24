//
//  LoadingStateView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//
import SwiftUI

struct LoadingStateView: View {

    var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
    }
}

struct LoadingStateView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingStateView()
    }
}
