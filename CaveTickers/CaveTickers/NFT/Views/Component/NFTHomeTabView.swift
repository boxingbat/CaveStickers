//
//  NFTHomeTabView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI

struct NFTHomeTabView: View {
    @EnvironmentObject var manager: NFTDataManager
    @Binding var showAssetDetails: Bool
    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 0) {
                sectionHeader(title: "New Releases") {
                    manager.newReleasedNFTItems.removeAll()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        manager.fetchNewReleasedItems()
                    }
                }.foregroundColor(Color.theme.accent)
                NFTItemsCarouselView() { item in
                    manager.selectedNFTItem = item
                    showAssetDetails = true
                }
            }
            VStack(spacing: 0) {
                Divider()
                ScrollView(.vertical, showsIndicators: false, content: {
                    sectionHeader(title: "Last Sold") {
                        manager.lastSoldNFTItems.removeAll()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            manager.fetchLastSoldItems()
                        }
                    }.foregroundColor(Color.theme.accent).padding(.top, 10)
                    NFTItemListView() { item in
                        manager.selectedNFTItem = item
                        showAssetDetails = true
                    }.padding([.leading, .trailing])
                    Spacer(minLength: 70)
                })
            }
        }.padding(.top, DashboardContentView.headerHeight / 3)
    }
    private func sectionHeader(title: String, refresh: @escaping () -> Void) -> some View {
        HStack {
            Text(title).font(.system(size: 20, weight: .medium))
            Spacer()
            Button(action: {
                UIImpactFeedbackGenerator().impactOccurred()
                refresh()
            }, label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 22, weight: .medium))
            })
        }.padding([.leading, .trailing], 30)
    }
}

struct NFTHomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        NFTHomeTabViewPreviews()
    }

    struct NFTHomeTabViewPreviews: View {
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

            return NFTHomeTabView(showAssetDetails: $showDetails)
                .environmentObject(manager)
        }
    }
}
