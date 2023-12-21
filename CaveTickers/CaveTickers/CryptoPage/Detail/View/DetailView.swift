//
//  DetailView.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/1.
//

import SwiftUI

struct DetailLoadingView: View {
    @Binding var coin: CoinModel?
    var body: some View {
        ZStack {
            if let coin = coin {
                DetailView(coin: coin)
            }
        }
    }
}

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @ObservedObject var webSocketManager = WebSocketManager()
    @State private var isFavorite = false
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing: CGFloat = 30

    init(coin: CoinModel) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(coin: coin))
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CryptoChartView(coin: viewModel.coin)
                    .padding(.vertical)
                overViewTitle
                HStack(spacing: spacing) {
                    realTimeView
                        .frame(maxWidth: .infinity, alignment: .leading)
                    currencyView
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: -13, y: 0)
                }
                .frame(maxWidth: .infinity)
                Divider()
                overViewGrid
                additionGrid
            }
            .padding()
        }
        .navigationTitle(viewModel.coin.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                navigationBarTraillingItems
            }
        }
        .onAppear {
            isFavorite = viewModel.ifCoinInPortfolio(coinID: viewModel.coin.id)
            webSocketManager.connect(withSymbol: "BINANCE:\(viewModel.coin.name.uppercased())USDT")
            webSocketManager.send(symbol: "BINANCE:\(viewModel.coin.symbol.uppercased())USDT")
        }
        .onDisappear {
            webSocketManager.close()
        }
    }
    private var realTimeView: some View {
        VStack(alignment: .leading) {
            Text("Real Time")
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)

            Text(webSocketManager.latestPrice)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(webSocketManager.flashColor == .clear ? Color.theme.accent : webSocketManager.flashColor)
        }
    }

    private var currencyView: some View {
        Text("\(viewModel.coin.symbol.uppercased()) / USDT")
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(Color.theme.secondaryText)
            .padding(.top, 20)
        }

    private func saveButtonTapped() {
        let coin = viewModel.coin
        let amount = 1
        if !isFavorite {
            viewModel.updatePortfolio(coin: coin, amount: Double(amount))
        } else {
            viewModel.deleteCoin(coin: coin)
        }
        isFavorite.toggle()
    }
}
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(coin: dev.coin)
        }
    }
}

extension DetailView {
    private var navigationBarTraillingItems: some View {
        HStack {
            Text(viewModel.coin.symbol.uppercased())
                .font(.headline)
            .foregroundColor(Color.theme.accent)
            CoinImageView(coin: viewModel.coin)
                .frame(width: 25, height: 25)
        }
    }
    private var overViewTitle: some View {
        HStack {
            Text("Market Overview")
                .font(.title)
                .bold()
                .foregroundColor(Color.theme.accent)

            Spacer()

            Button(action: {
                saveButtonTapped()
            })
            {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private var overViewGrid: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: spacing,
            pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/ ) {
            ForEach(viewModel.overviewStatistics) { stat in
                StatisticView(stat: stat)
            }
        }
    }
    private var additionTitle: some View {
        Text("Addition Detials")
            .font(.title)
            .bold()
            .foregroundColor(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    private var additionGrid: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: spacing,
            pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/ ) {
            ForEach(viewModel.addtionalStatistics) { stat in
                StatisticView(stat: stat)
            }
        }
    }
}
