//
//  PortfolioView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/30.
//

import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var selectedCoin: CoinModel?
    @State private var quantityText: String = ""
    @State private var showCheckmark = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SearchBarView(searchText: $viewModel.searchText)
                    coinLogoList
                    if selectedCoin != nil {
                        portfolioInputSection
                    }
                }
            }
            .navigationTitle("Edit")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    XmarkButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingNavBarButton
                }
            })
            .onChange(of: viewModel.searchText, perform: { value in
                if value.isEmpty {
                    removeSelectedCoin()
                }
            })
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
            .environmentObject(dev.homeVM)
    }
}
extension PortfolioView {
    private var coinLogoList: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            LazyHStack(spacing: 10) {
                ForEach(viewModel.allCoins) { coin in
                    CoinLogoView(coin: coin)
                        .frame(width: 75)
                        .padding(4)
                        .onTapGesture {
                            withAnimation(.easeIn) {
                                updatedSelectedCoin(coin: coin)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedCoin?.id == coin.id ? Color.theme.green : Color.clear,
                                lineWidth: 1)
                        )
                }
            }
            .frame(height: 120)
            .padding(.leading)
        }
    }
    private func updatedSelectedCoin(coin: CoinModel) {
        selectedCoin = coin

        if let portfolioCoin = viewModel.portfolioCoins.first(where: { $0.id == coin.id }),
        let amount = portfolioCoin.currentHoldings {
            quantityText = "\(amount)"
        } else {
            quantityText = ""
        }
    }

    private func getCurrentValue() -> Double {
        if let quantity = Double(quantityText) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        return 0
    }
    private var portfolioInputSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("current price of \(selectedCoin?.symbol.uppercased() ?? ""):")
                Spacer()
                Text(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")
            }
            Divider()
            HStack {
                Text("Amount:")
                Spacer()
                TextField("EX: 1,4", text: $quantityText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            Divider()
            HStack {
                Text("Current Value:")
                Spacer()
                Text(getCurrentValue().asCurrencyWith2Decimals())
            }
        }
        .padding()
        .font(.headline)
    }

    private var trailingNavBarButton: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .opacity(showCheckmark ? 1.0 : 0.0)

            Button(action: {
                saveButtonTapped()
            }, label: {
                Text("Save".uppercased())
            })
            .opacity(
                (selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText)) ? 1.0 : 0.0)
        }
        .font(.headline)
    }

    private func saveButtonTapped() {
        guard
            let coin = selectedCoin,
            let amount = Double(quantityText)
        else { return }

        // Save
        viewModel.updatePortfolio(coin: coin, amount: amount)


        withAnimation(.easeIn) {
            showCheckmark = true
            removeSelectedCoin()
        }

        UIApplication.shared.endEditing()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCheckmark = false
        }
    }

    private func removeSelectedCoin() {
        selectedCoin = nil
        viewModel.searchText = ""
    }
}
