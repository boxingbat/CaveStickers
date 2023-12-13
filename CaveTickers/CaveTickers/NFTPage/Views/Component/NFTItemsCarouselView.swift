//
//  NFTItemsCarouseView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI

struct NFTItemsCarouselView: View {
    @EnvironmentObject var manager: NFTDataManager
    private let width: CGFloat = UIScreen.main.bounds.width / 1.8
    let didSelectItem: (_ item: NFTAssetModel) -> Void

    var body: some View {
        ZStack {
            if manager.newReleasedNFTItems.isEmpty {
                loadingStateView
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    Spacer(minLength: 10)
                    ForEach(0..<manager.newReleasedNFTItems.count, id: \.self) { index in
                        carouselItem(atIndex: index)
                    }
                    Spacer(minLength: 10)
                }
            }
        }
    }

    private func carouselItem(atIndex index: Int) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            didSelectItem(manager.newReleasedNFTItems[index])
        }, label: {
            VStack {
                RemoteImage(assetModel: AssetModel(model: manager.newReleasedNFTItems[index]))
                    .frame(width: width - 40,
                        height: width / 1.3,
                        alignment: .center)
                    .cornerRadius(18)
                    .padding([
                        .leading,
                        .trailing,
                        .top
                    ], 10)
                HStack {
                    Text(manager.newReleasedNFTItems[index].name).foregroundColor(Color.gray)
                    Spacer()
                }.lineLimit(1).padding([.leading, .trailing])
            }.frame(width: width)
        })
            .shadow(color: Color.accentColor.opacity(1), radius: 8)

        .padding()
    }

    private var loadingStateView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(Color("TileColor"))
                .shadow(color: Color.black.opacity(0.12), radius: 8)
            VStack {
                Text("Please Wait...").font(.system(size: 20)).bold()
                Text("Loading NFT assets")
            }.foregroundColor(Color.gray)
        }
        .colorScheme(.light)
        .frame(height: width / 1.3,
            alignment: .center)
        .padding([.leading, .trailing], 25)
        .padding(.top)
    }
}

struct TrendingCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = NFTDataManager()
        manager.newReleasedNFTItems = [
            demoAssetModel, demoAssetModel
        ]
        return NFTItemsCarouselView { _ in }.environmentObject(manager)
    }
}
