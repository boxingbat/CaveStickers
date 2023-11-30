//
//  CryptoHomePageView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/29.
//

import SwiftUI

struct CryptoHomePageView: View {
    @StateObject var viewModel: HomeViewModel
    @State private var showPortfolio: Bool = false

    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()

            VStack {
                homeHeader

                columTitles

                if !showPortfolio {
                    allCoinList
                        .transition(.move(edge: .leading))
                }
                if showPortfolio {
                    portfolioCoinList
                        .transition(.move(edge: .trailing))
                }
                Spacer(minLength: 0)
            }
        }
    }
}

struct CryptoHomePageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CryptoHomePageView(viewModel: HomeViewModel())
                .navigationBarHidden(true)
        }
        .environmentObject(dev.homeVM)
    }
}

extension CryptoHomePageView {
    private var homeHeader: some View {
        HStack {
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(.none)
                .background(
                    CircleButtonAnimationView(animate: $showPortfolio)
                )
            Spacer()
            Text(showPortfolio ? "Watchlist" : "LivePrice")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()) {
                        showPortfolio.toggle()
                    }
                }
        }
        .padding(.horizontal)
    }
    private var allCoinList: some View {
        List {
            ForEach(viewModel.allCoins) { coin in
                CoinRowView(coin: coin, showHoldingColum: false)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
        }
        .listStyle(PlainListStyle())
    }

    private var portfolioCoinList: some View {
        List {
            ForEach(viewModel.allCoins) { coin in
                CoinRowView(coin: coin, showHoldingColum: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
        }
        .listStyle(PlainListStyle())
    }
    private var columTitles: some View {
        HStack {
            Text("Coin")
            Spacer()
            if showPortfolio {
                Text("Holding")
            }
            Text("Price")
                .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .padding(.horizontal)
    }
}
