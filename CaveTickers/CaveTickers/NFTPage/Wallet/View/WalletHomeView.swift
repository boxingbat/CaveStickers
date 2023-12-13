//
//  WalletHomeView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/2.
//

import SwiftUI

struct WalletHomeView: View {
    @StateObject var metaMaskRepo = MetaMaskRepo()
    @State private var status = "Offline"
    @EnvironmentObject var manager: NFTDataManager
    @Binding var showAssetDetails: Bool
    @State private var ownerAddress: String?
    @State private var isFlashing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Status")
                        .foregroundColor(.theme.secondaryText)
                        .font(.system(size: 10))
                    HStack {
                        if metaMaskRepo.connectionStatus == "Connected" {
                            FlashingView()
                                .frame(width: 10, height: 10)
                        }
                        Text("\(metaMaskRepo.connectionStatus)")
                            .fontWeight(.medium)
                            .foregroundColor(metaMaskRepo.statusColor)
                            .font(.system(size: 16))
                    }
                }
                Spacer()
                VStack(alignment: .center) {
                    Text("Chain ID")
                        .foregroundColor(.theme.secondaryText)
                        .font(.system(size: 10))
                        .padding(.horizontal, 50)
                    Text("\(metaMaskRepo.chainID)")
                        .fontWeight(.medium)
                        .foregroundColor(.theme.accent)
                }
            }
            .padding(.horizontal, 50)
            HStack {
                Button {
                    metaMaskRepo.connectToDapp()
                } label: {
                    Image("fox")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                    .background(Color.clear)
                    .buttonStyle(PlainButtonStyle())
                    .shadow(color: .theme.accent.opacity(0.6), radius: 10, x: 0, y: 2)
                    .shadow(color: .theme.accent.opacity(0.3), radius: 10, x: 0, y: 4)

                VStack(alignment: .leading) {
                    Text("Address")
                        .foregroundColor(.theme.secondaryText)
                        .font(.system(size: 10))
                        .padding(.leading, 8)
                    Text("\(metaMaskRepo.ethAddress)")
                        .fontWeight(.medium)
                        .foregroundColor(.theme.secondaryText)
                        .font(.system(size: 12))
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 50)
            HStack {
                Button {
                    metaMaskRepo.getBalance()
                    manager.fetchHoldingItems()
                    manager.generateMockHoldingNFTItems() // for demo only
                } label: {
                    Image("024-crypto")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                    .background(Color.clear)
                    .buttonStyle(PlainButtonStyle())
                    .shadow(color: .theme.accent.opacity(0.6), radius: 10, x: 0, y: 2)
                    .shadow(color: .theme.accent.opacity(0.3), radius: 10, x: 0, y: 4)
                VStack(alignment: .leading) {
                    Text("Balance")
                        .foregroundColor(.theme.secondaryText)
                        .font(.system(size: 10))
                        .padding(.leading, 8)
                    Text("\(metaMaskRepo.balance)")
                        .fontWeight(.medium)
                        .foregroundColor(.theme.accent)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 50)
            if !manager.holdingNFTItems.isEmpty {
                NFTHoldingCarouseView { item in
                    manager.selectedNFTItem = item
                    showAssetDetails = true
                }
                .padding(.top, 20)
            }
            Spacer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .Connection)) { notification in
            status = notification.userInfo?["value"] as? String ?? "Offline"
        }
        .padding(.top, DashboardContentView.headerHeight / 3)
    }
}

struct WalletHomeView_Previews: PreviewProvider {
    static var previews: some View {
        WalletHomeViewPreviews()
    }

    struct WalletHomeViewPreviews: View {
        @State private var showDetails = false

        // MARK: - Main rendering function
        var body: some View {
            let manager = NFTDataManager()
            manager.newReleasedNFTItems = [
                demoAssetModel, demoAssetModel
            ]

            manager.lastSoldNFTItems = [
                demoAssetModel, demoAssetModel
            ]

            return WalletHomeView(showAssetDetails: $showDetails)
                .environmentObject(manager)
        }
    }
}
struct FlashingView: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(Color.themeGreen)
            .opacity(isAnimating ? 1 : 0)
            .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}
