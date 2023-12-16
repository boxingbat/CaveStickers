//
//  ChartView.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//

import SwiftUI
import XCAStocksAPI

struct StockTickerView: View {
    @StateObject var chartVM: ChartViewModel
    @ObservedObject var webSocketManager = WebSocketManager()
    @Environment(\
        .dismiss
    )
    private var dismiss
    @State private var selectedRange = ChartRange.oneDay
    @State private var isFavorite = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView.padding(.horizontal)
            Divider()
                .padding(.vertical, 8)
                .padding(.horizontal)
            scrollView
        }
        .padding(.top)
        .background(Color(uiColor: .systemBackground))
        .task(id: chartVM.selectedRange.rawValue) {
            await chartVM.fetchData()
        }
    }

    private var scrollView: some View {
        ScrollView {
            ZStack {
                DateRangePickerView(selectedRange: $chartVM.selectedRange)
                    .opacity(chartVM.selectedXOpacity)

                Text(chartVM.selectedXDateText)
                    .font(.headline)
                    .padding(.vertical, 4)
                    .padding(.horizontal)
            }
            Divider().opacity(chartVM.selectedXOpacity)

            chartView
                .padding(.horizontal)
                .frame(maxWidth: .infinity, minHeight: 220)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            isFavorite = PersistenceManager.shared.watchlistContains(symbol: chartVM.ticker.symbol)
            chartVM.getCurrentPrice()
        }
        .onDisappear {
            chartVM.disconnectWebSocket()
        }
    }

    @ViewBuilder private var chartView: some View {
        switch chartVM.fetchphase {
        case .fetching:
            LoadingStateView(isLoading: true)
        case .success(let data):
            ChartView(data: data, viewModel: chartVM)
        case .failure(let error):
            ErrorStateView(error: "Chart: \(error.localizedDescription)")
        default:
            EmptyView()
        }
    }
    private var headerView: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(chartVM.ticker.symbol)
                .font(.title.bold())
                .foregroundColor(.theme.accent)
            Text(chartVM.latestPrice)
                .font(.title2.bold())
                .foregroundColor(webSocketManager.flashColor == .clear ? Color.theme.accent : webSocketManager.flashColor)
            Spacer()
            Button(action: {
                isFavorite.toggle()
                if isFavorite {
                    PersistenceManager.shared.addToWatchList(symbol: chartVM.ticker.symbol, companyName: "")
                } else {
                    PersistenceManager.shared.removeFromWatchList(symbol: chartVM.ticker.symbol )
                }
            }, label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
            })
        }
    }
}
    struct StockTickerView_Previews: PreviewProvider {
        static var tradingStubsQuoteVM:
        TickerQuoteViewModel = {
            var mockAPI = MockStocksAPI()
            mockAPI.stubbedFetchQuotesCallback = {
                [Quote.stub(isTrading: true)]
            }
            return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
        }()

        static var closedStubsQuoteVM: TickerQuoteViewModel = {
            var mockAPI = MockStocksAPI()
            mockAPI.stubbedFetchQuotesCallback = {
                [Quote.stub(isTrading: false)]
            }
            return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
        }()
        static var loadingStubsQuoteVM: TickerQuoteViewModel = {
            var mockAPI = MockStocksAPI()
            mockAPI.stubbedFetchQuotesCallback = {
                await withCheckedContinuation { _ in
                }
            }
            return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
        }()
        static var errorStubsQuoteVM: TickerQuoteViewModel = {
            var mockAPI = MockStocksAPI()
            mockAPI.stubbedFetchQuotesCallback = {
            throw NSError(domain: "error", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error has been occured"])
            }
            return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
    }()
        static var chartVM: ChartViewModel {
            ChartViewModel(ticker: .stub, apiService: MockStocksAPI())
        }

        static var previews: some View {
            Group {
                StockTickerView(chartVM: chartVM)
                    .previewDisplayName("Trading")
                    .frame(height: 700)

                StockTickerView(chartVM: chartVM)
                    .previewDisplayName("Closed")
                    .frame(height: 700)

                StockTickerView(chartVM: chartVM)
                    .previewDisplayName("Loading Quote")
                    .frame(height: 700)

                StockTickerView(chartVM: chartVM)
                    .previewDisplayName("Error Quote")
                    .frame(height: 700)
            }.previewLayout(.sizeThatFits)
        }}
