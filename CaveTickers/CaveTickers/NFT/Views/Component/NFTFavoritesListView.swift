//
//  NFTFavoritesListView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI

struct NFTFavoritesListView: View {
    @EnvironmentObject var datamanager: NFTDataManager
    private let width: CGFloat = UIScreen.main.bounds.width / 2 - 50
    private let grid = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    let didSelectItem: (_ item: NFTAssetModel) -> Void
    var body: some View {
        LazyVGrid(columns: grid, spacing: 20, content: {
            ForEach(0..<datamanager.favoriteNFTItems.count, id: \.self) { index in
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    didSelectItem(datamanager.favoriteNFTItems[index])
                }, label: {
                    VStack {
                        RemoteImage(assetModel: AssetModel(model: datamanager.favoriteNFTItems[index]))
                            .frame(width: width, height: width, alignment: .center)
                            .cornerRadius(18)
                            .padding([
                                .leading,
                                .trailing,
                                .top
                            ], 10)
                        Text(datamanager.favoriteNFTItems[index].name)
                            .font(.system(size: 18))
                            .lineLimit(1)
                            .padding([.leading, .trailing, .bottom], 10)
                            .foregroundColor(Color("DarkColor"))
                    }
                })
                .background(
                    Color.gray.cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.12), radius: 8)
                )
            }
        })
    }
}

struct NFTFavoritesListView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = NFTDataManager()
        manager.favoriteNFTItems = [
            demoAssetModel, demoAssetModel
        ]
        return NFTFavoritesListView { _ in }
            .environmentObject(manager)
    }
}
