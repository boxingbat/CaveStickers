//
//  NFTCollectionsTabView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI

struct NFTCollectionsTabView: View {
    @EnvironmentObject var manager: NFTDataManager
    @State private var showCollectionItems = false
    @Binding var showAssetDetails: Bool
    private let width: CGFloat = UIScreen.main.bounds.width / 2 - 50
    private let grid = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    var body: some View {
        VStack {
            if manager.collections.isEmpty {
                emptyStateView
            }
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: grid, spacing: 20) {
                    ForEach(0..<manager.collections.count, id: \.self) { index in
                        collectionItem(atIndex: index)
                    }
                }.padding([.leading, .trailing], 20)
                Spacer(minLength: 90)
            }
            //        }.padding(.top, DashboardContentView.headerHeight/3).onAppear() {
            //            manager.fetchCollections()
            //        }.sheet(isPresented: $showCollectionItems, content: {
            //            collectionItemsContentView() { selectedItem in
            //                manager.selectedNFTItem = selectedItem
            //                showAssetDetails = true
            //            }.environmentObject(manager)
            //        })
        }
    }
    private func collectionItem(atIndex index: Int) -> some View {
        let collections = manager.collections.keys.sorted { $0.rawValue < $1.rawValue }
        let collectionType = collections[index]
        let model = manager.collections[collectionType]!
        return
            Button(action: {
                UIImpactFeedbackGenerator().impactOccurred()
                manager.selectedCollection = collectionType
                showCollectionItems.toggle()
            }, label: {
                VStack {
                    RemoteImage(assetModel: AssetModel(model: model, collectionImage: true))
                        .frame(width: width, height: width, alignment: .center)
                        .cornerRadius(18)
                        .padding([.leading, .trailing, .top], 10)
                    Text(collectionType.rawValue.capitalized)
                        .font(.system(size: 18))
                        .lineLimit(1)
                        .padding([.leading, .trailing, .bottom], 10)
                        .foregroundColor(Color("DarkColor"))
                }
            }).background(
                Color("TileColor").cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.12), radius: 8)
            )
    }

    /// Empty state
    private var emptyStateView: some View {
        VStack {
            Spacer(minLength: 20)
            Text("Please Wait...").font(.system(size: 20)).bold()
            Text("Loading NFT collections")
        }.foregroundColor(Color("DarkColor")).padding().colorScheme(.light)
    }
}

struct NFTCollectionsTabView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsTabViewPreview()
    }

    struct CollectionsTabViewPreview: View {
        @State var showDetails = false

        // MARK: - Main rendering function
        var body: some View {
            let manager = NFTDataManager()
            manager.favoriteNFTItems = [
                demoAssetModel, demoAssetModel
            ]
            return NFTCollectionsTabView(showAssetDetails: $showDetails)
                .environmentObject(manager)
        }
    }
}
