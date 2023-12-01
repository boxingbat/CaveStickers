//
//  SearchBarView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/30.
//

import SwiftUI

struct SearchBarView: View {

    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(
                    searchText.isEmpty ?
                    Color.theme.secondaryText : Color.theme.accent
                )

            TextField("Search by name or symbol", text: $searchText)
                .foregroundColor(Color.theme.accent)
                .overlay(
                         Image(systemName:  "xmark.circle.fill")
                            .padding()
                            .offset(x: 10)
                            .foregroundColor(Color.theme.accent)
                            .opacity(searchText.isEmpty ? 0.0 : 1.0)
                            .onTapGesture {
                                UIApplication.shared.endEditing()
                                searchText = ""
                            }
                         ,alignment: .trailing
                )
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.theme.background)
                .shadow(
                    color: Color.theme.accent.opacity(0.3),
                    radius: 10,
                    x: 0,
                    y: 0
                )
        )
        .padding()
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""))
            .preferredColorScheme(.dark)
    }
}
