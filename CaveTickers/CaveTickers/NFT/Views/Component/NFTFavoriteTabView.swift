//
//  NFTFavoriteTabView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI

/// Shows a list of favorite nft items
struct FavoriteTabView: View {

    @EnvironmentObject var manager: NFTDataManager
    @Binding var showAssetDetails: Bool

    // MARK: - Main rendering function
    var body: some View {
        VStack(spacing: 0) {
            if manager.favoriteNFTItems.isEmpty {
                emptyStateView
            }
            ScrollView(.vertical, showsIndicators: false, content: {
                NFTFavoritesListView() { item in
                    manager.selectedNFTItem = item
                    showAssetDetails = true
                }.padding([.leading, .trailing])
                Spacer(minLength: 90)
            }).padding([.leading, .trailing], 5)
        }.padding(.top, DashboardContentView.headerHeight / 3)
    }

    /// Empty state
    private var emptyStateView: some View {
        VStack {
            Spacer(minLength: 20)
            Text("Hmm...").font(.system(size: 20)).bold()
            Text("No Favorite NFTs here")
        }.foregroundColor(Color("DarkColor")).padding()
    }
}

// MARK: - Preview UI
struct FavoriteTabView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteTabViewPreviews()
    }

    struct FavoriteTabViewPreviews: View {
        @State private var showDetails: Bool = false

        // MARK: - Main rendering function
        var body: some View {
            let manager = NFTDataManager()
            manager.newReleasedNFTItems = [
                demoAssetModel, demoAssetModel
            ]

            manager.lastSoldNFTItems = [
                demoAssetModel, demoAssetModel
            ]

            return FavoriteTabView(showAssetDetails: $showDetails)
                .environmentObject(manager)
        }
    }
}
