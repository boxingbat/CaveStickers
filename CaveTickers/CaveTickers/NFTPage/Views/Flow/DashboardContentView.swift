//
//  DashboardContentView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI

struct DashboardContentView: View {
    @EnvironmentObject var manager: NFTDataManager
    @State private var showAssetDetails = false
    @State private var selectedTab: CustomTabBarItem = .home
    @State private var showWalletHome = false
    @State private var showFavorite = false
    static let headerHeight: CGFloat = UIScreen.main.bounds.height / 3.5
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            NFTDetailsNavigationLink
            headerView
            switch selectedTab {
            case .home:
                NFTHomeTabView(showAssetDetails: $showAssetDetails).environmentObject(manager)
            case .favorite:
                FavoriteTabView(showAssetDetails: $showAssetDetails).environmentObject(manager)
            case .collection:
                WalletHomeView(showAssetDetails: $showAssetDetails).environmentObject(manager)
            }
            navigationBarView
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            manager.fetchLastSoldItems()
            manager.fetchNewReleasedItems()
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
                VStack(spacing: 10) {
                    Text(selectedTab.headerTitle)
                        .font(.system(size: 30, weight: .medium))
//                        .foregroundColor(Color.theme.accent)
                    Capsule().frame(height: 1, alignment: .center)
                        .padding([
                            .leading,
                            .trailing
                        ], 40)
                        .opacity(0.4)
                    Spacer()
                }.foregroundColor(.gray).colorScheme(.light).padding(.top, 10)
            }.frame(height: height)
            Spacer()
        }
    }

    /// Navigation bottom bar
    private var navigationBarView: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        ForEach(CustomTabBarItem.allCases) { tab in
                            Button(action: {
                                selectedTab = tab
                            }, label: {
                                Image(systemName: "\(tab.rawValue)\(selectedTab == tab ? ".fill" : "")")
                                    .font(.system(size: 25, weight: selectedTab == tab ? .bold : .regular))
                                    .foregroundColor(Color.secondary)
                                    .opacity(selectedTab == tab ? 1 : 0.4)
                            }).frame(width: 40, height: 40, alignment: .center)
                        }
                    }
                    .padding()
                    .background(Color.clear)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
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
                              isActive: $showAssetDetails) {
            EmptyView()
        }
        .hidden()
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
