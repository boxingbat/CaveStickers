//
//  AssetDetailsContentView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI
import SafariServices

/// Shows a full screen with a given asset details
struct AssetDetailsContentView: View {
    @EnvironmentObject var manager: NFTDataManager
    @Environment(\.presentationMode) 
    var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var dragAmount = CGSize.zero
    private let width: CGFloat = UIScreen.main.bounds.width - 40
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack(spacing: 15) {
                backButtonView
                ScrollView(.vertical, showsIndicators: false) {
                    headerView
                    selectedItemImage
                    selectedItemDescription.padding(.top)
                    Spacer(minLength: 20)
                }
                shareButtonView
            }.padding(20)
        }
        .environmentObject(manager)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }

    /// Back button
    private var backButtonView: some View {
        HStack {
            Button(action: {
                UIImpactFeedbackGenerator().impactOccurred()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
            })
            Spacer()
        }.foregroundColor(Color.theme.accent)
    }

    /// Header view
    private var headerView: some View {
        VStack {
            HStack(spacing: 10) {
                Text(manager.selectedNFTItem?.name ?? "unknown").font(.system(size: 30, weight: .black))
                Spacer()
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    manager.favoriteSelectedItemIfNeeded()
                }, label: {
                    Image(systemName: "heart\(manager.isSelectedItemFavorite ? ".fill" : "")")
                        .font(.system(size: 25))
                }).foregroundColor(Color.theme.accent)
            }
            HStack {
                Text("Created by")
                Text(manager.selectedNFTItem?.creator?.user.username ?? "SKC37624")
                    .font(.system(size: 18))
                    .bold()
                    .foregroundColor(Color.theme.accent)
                Spacer()
            }
        }
    }

    /// Item image
    /// Item image
    private var selectedItemImage: some View {
        ZStack {
            if let item = manager.selectedNFTItem {
                RemoteImage(assetModel: AssetModel(model: item, thumbnail: false))
                    .frame(width: width, height: width / 1.3, alignment: .center)
                    .cornerRadius(18)
                    .contentShape(Rectangle())
                    .shadow(color: Color.accentColor.opacity(1), radius: 8)
                    .scaleEffect(scale)
                    .offset(dragAmount)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                self.scale = value.magnitude
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                self.dragAmount = value.translation
                            }
                            .onEnded { _ in
                                withAnimation {
                                    self.dragAmount = .zero
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            self.scale = 1.0
                            self.dragAmount = .zero
                        }
                    }
                    .padding(.horizontal) // Add horizontal padding
            }
        }
    }


    /// Item description
    private var selectedItemDescription: some View {
        VStack {
            sectionHeader(title: "Description")
            Spacer()
            HStack {
                Text(manager.selectedNFTItem?.nftAssetDescription.itemDescription ?? "n/a")
                Spacer()
            }
                VStack {
                    sectionHeader(title: "Sales Count")
                        .foregroundColor(.theme.secondaryText)
                    HStack {
                        Text("Lastest Selling Count : \(manager.selectedNFTItem?.salesCount ?? 0)")
                        Spacer()
                    }
                }
                Spacer()
            VStack(alignment: .trailing) {
                sectionHeader(title: "Item Price")
                    .foregroundColor(.theme.secondaryText)
                Spacer()
                HStack {
                    if let item = manager.selectedNFTItem {
                        Text("Latest Selling Price : \(manager.price(forAsset: item))")
                    } else {
                        Text("0.8652ETH")
                    }
                    Spacer()
                }
            } .padding(.top, 20)
        }.fixedSize(horizontal: false, vertical: true)
            .foregroundColor(Color.theme.accent)
    }

    /// Section header view
    private func sectionHeader(title: String, leftAligned: Bool = true) -> some View {
        HStack {
            if leftAligned == false { Spacer() }
            Text(title).font(.system(size: 20, weight: .medium))
            if leftAligned { Spacer() }
        }
    }

    /// Share button
    private var shareButtonView: some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            if let url = URL(string: manager.selectedNFTItem?.permalink ?? "https://opensea.io") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.white)
                Text("More Details")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }
        })
        .frame(height: 50)
        .colorScheme(.dark)
        .shadow(color: Color.accentColor.opacity(1), radius: 8)
    }
}

// MARK: - Preview UI
struct AssetDetailsContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = NFTDataManager()
        manager.newReleasedNFTItems = [
            demoAssetModel, demoAssetModel
        ]

        manager.lastSoldNFTItems = [
            demoAssetModel, demoAssetModel
        ]

        manager.selectedNFTItem = manager.lastSoldNFTItems[0]

        return AssetDetailsContentView().environmentObject(manager)
    }
}
