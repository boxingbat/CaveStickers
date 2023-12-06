//
//  DashboardContentView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI

struct DashboardContentView: View {

    @EnvironmentObject var manager: NFTDataManager
    @State private var showAssetDetails: Bool = false
    @State private var selectedTab: CustomTabBarItem = .home
    @State private var showWalletHome: Bool = false
    static let headerHeight: CGFloat = UIScreen.main.bounds.height / 3.5

    // MARK: - Main rendering function
    var body: some View {
        NavigationView {
            ZStack {
                NFTDetailsNavigationLink
//                Color("BackgroundColor").ignoresSafeArea()
                headerView
                switch selectedTab {
                case .home:
                    NFTHomeTabView(showAssetDetails: $showAssetDetails).environmentObject(manager)
                case .favorite:
                    FavoriteTabView(showAssetDetails: $showAssetDetails).environmentObject(manager)
                case .collection:
                    NFTCollectionsTabView(showAssetDetails: $showAssetDetails).environmentObject(manager)
                }
                NavigationLink(destination: WalletHomeView(), isActive: $showWalletHome) { EmptyView() }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("").navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear() {
                manager.fetchLastSoldItems()
                manager.fetchNewReleasedItems()
            }
            navigationBarView
        }
    }

    /// Header view
    private var headerView: some View {
        var height = DashboardContentView.headerHeight
        if selectedTab == .favorite && manager.favoriteNFTItems.isEmpty {
            height = DashboardContentView.headerHeight / 3
        }
        if selectedTab == .collection && manager.collections.isEmpty {
            height = DashboardContentView.headerHeight / 3
        }
        return VStack {
            ZStack {
                //                Color.accentColor.ignoresSafeArea()
                VStack(spacing: 10) {

                    HStack {
                        Button(action: {
                            showWalletHome = true
                        }) {
                            Image("metaMask")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .foregroundColor(.background)
                        }
                        Text(selectedTab.headerTitle)
                            .font(.system(size: 30, weight: .black))
                    }
                    Capsule().frame(height: 1, alignment: .center)
                        .padding([.leading, .trailing], 40).opacity(0.4)
                    Spacer()
                }.foregroundColor(.white).colorScheme(.light).padding(.top, 10)
            }.frame(height: height)
            Spacer()
        }
    }

    /// Navigation bottom bar
    private var navigationBarView: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedCorner(radius: 40, corners: [.topLeft, .topRight])
                    .foregroundColor(.accentColor).ignoresSafeArea()
                    .shadow(color: Color.black.opacity(0.12), radius: 8)
                HStack(spacing: 30) {
                    ForEach(CustomTabBarItem.allCases) { tab in
                        Button(action: {
                            selectedTab = tab
                        }, label: {
                            Image(systemName: "\(tab.rawValue)\(selectedTab == tab ? ".fill" : "")")
                                .font(.system(size: 25, weight: selectedTab == tab ? .bold : .regular))
                                .foregroundColor(Color("TileColor"))
                                .opacity(selectedTab == tab ? 1 : 0.4)
                        }).frame(width: 40, height: 40, alignment: .center)
                    }.colorScheme(.light)
                }
            }.frame(height: 40)
        }
    }

    /// Navigation link for NFT details view
    private var NFTDetailsNavigationLink: some View {
        func destinationView() -> some View {
            ZStack {
                if showAssetDetails {
                    AssetDetailsContentView().environmentObject(manager)
                }
            }
        }
        return NavigationLink(destination: destinationView(),
                              isActive: $showAssetDetails, label: { EmptyView() }).hidden()
    }
}

// MARK: - Preview UI
struct DashboardContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = NFTDataManager()
        manager.newReleasedNFTItems = [
            demoAssetModel, demoAssetModel
        ]

        manager.lastSoldNFTItems = [
            demoAssetModel, demoAssetModel
        ]

        manager.favoriteNFTItems = manager.lastSoldNFTItems

        return DashboardContentView().environmentObject(manager)
    }
}
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
