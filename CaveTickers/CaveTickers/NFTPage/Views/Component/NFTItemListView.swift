//
//  NFTItemListView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI

struct NFTItemListView: View {
    @EnvironmentObject var datamanager: NFTDataManager
    private let height: CGFloat = 65
    let didSelectItem: (_ item: NFTAssetModel) -> Void
    var body: some View {
        if datamanager.lastSoldNFTItems.isEmpty {
            loadingStateView
        }
        VStack(spacing: 0) {
            ForEach(0..<datamanager.lastSoldNFTItems.count, id: \.self) { index in
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    didSelectItem(datamanager.lastSoldNFTItems[index])
                }, label: {
                    listItem(index: index)
                })
            }
            if !datamanager.lastSoldNFTItems.isEmpty {
                openSeaLogoView
            }
        }
    }
    private var loadingStateView: some View {
        VStack {
            Spacer(minLength: 20)
            Text("Hold on...").font(.system(size: 20)).bold()
            Text("Looking for last sold NFTs")
        } .foregroundColor(Color.gray).padding().colorScheme(.light)
    }

    private func listItem(index: Int) -> some View {
        HStack {
            RemoteImage(assetModel: AssetModel(model: datamanager.lastSoldNFTItems[index]))
                .frame(width: height, height: height, alignment: .center)
                .cornerRadius(15)
                .padding(10)
            Text(datamanager.lastSoldNFTItems[index].name)
                .font(.system(size: 20))
                .foregroundColor(.secondary)
                .lineLimit(1)
            Spacer()
        }
    }
private var openSeaLogoView: some View {
    HStack {
        Spacer()
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            UIApplication.shared.open(URL(string: AppConfig.openSeaAPIDocs)!, options: [:], completionHandler: nil)
        }, label: {
            Image("opensea-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30, alignment: .center)
        })
        Spacer()
    }
    .padding(20)
    .foregroundColor(Color.gray)
    .opacity(0.1)
    }
}

struct NFTItemListView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = NFTDataManager()
        manager.lastSoldNFTItems = [
            demoAssetModel, demoAssetModel
        ]
        return NFTItemListView { _ in }.environmentObject(manager)
    }
}
