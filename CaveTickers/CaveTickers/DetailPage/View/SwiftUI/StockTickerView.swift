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
    @StateObject var quoteVM: TickerQuoteViewModel
    @ObservedObject var webSocketManager = WebSocketManager()
    @Environment(\
        .dismiss
    )
    private var dismiss
    @State private var selectedRange = ChartRange.oneDay
    public var symbol: String?
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
            if quoteVM.quote == nil {
                await quoteVM.fetchQuote()
            }
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
            isFavorite = PersistenceManager.shared.watchlistContains(symbol: symbol ?? "")
            webSocketManager.connect(withSymbol: symbol ?? "AAPL")
            webSocketManager.send(symbol: symbol ?? "AAPL")
        }
        .onDisappear {
            webSocketManager.close()
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
    @ViewBuilder private var quoteDetailRowView: some View {
        switch quoteVM.phase {
        case .fetching: LoadingStateView(isLoading: true)
        case .failure(let error): ErrorStateView(error: "Quote: \(error.localizedDescription)")
            .padding(.horizontal)
        case .success(let quote):
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(quote.columnItems) {
                        QuoteDetailRowColumnView(item: $0)
                    }
                }
                .padding(.horizontal)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
            }
            .scrollIndicators(.hidden)
        default: EmptyView()
        }
    }
    private var priceDiffRowView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let quote = quoteVM.quote {
                HStack {
                    if quote.isTrading,
                    let price = quote.regularPriceText,
                    let diff = quote.regularDiffText {
                        priceDiffStackView(price: price, diff: diff, caption: nil)
                    } else {
                        if let atCloseText = quote.regularPriceText,
                        let atCloseDiffText = quote.regularDiffText {
                            priceDiffStackView(price: atCloseText, diff: atCloseDiffText, caption: "At Close")
                        }

                        if let afterHourText = quote.postPriceText,
                        let afterHourDiffText = quote.postPriceDiffText {
                            priceDiffStackView(price: afterHourText, diff: afterHourDiffText, caption: "After Hours")
                        }
                    }

                    Spacer()
                }
            }
            exchangeCurrencyView
        }
    }

    private func priceDiffStackView(price: String, diff: String, caption: String?) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .lastTextBaseline, spacing: 16) {
                Text(price).font(.headline.bold())
                Text(diff).font(.subheadline.weight(.semibold))
                    .foregroundColor(diff.hasPrefix("-") ? .red : .green)
            }

            if let caption {
                Text(caption)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        }
    }
    private var exchangeCurrencyView: some View {
        HStack(spacing: 4) {
            if let exchange = quoteVM.ticker.exchDisp {
                Text(exchange)
            }
            if let currency = quoteVM.quote?.currency {
                Text("·")
                Text(currency)
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundColor(Color(uiColor: .secondaryLabel))
    }
    private var headerView: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(quoteVM.ticker.symbol)
                .font(.title.bold())
                .foregroundColor(.theme.accent)
            Text(webSocketManager.latestPrice)
                .font(.title2.bold())
                .foregroundColor(webSocketManager.flashColor == .clear ? Color.theme.accent : webSocketManager.flashColor)
            Spacer()
            Button(action: {
                isFavorite.toggle()
                if isFavorite {
                    PersistenceManager.shared.addToWatchList(symbol: symbol ?? "", companyName: "")
                } else {
                    PersistenceManager.shared.removeFromWatchList(symbol: symbol ?? "")
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
                StockTickerView(chartVM: chartVM, quoteVM: tradingStubsQuoteVM)
                    .previewDisplayName("Trading")
                    .frame(height: 700)

                StockTickerView(chartVM: chartVM, quoteVM: closedStubsQuoteVM)
                    .previewDisplayName("Closed")
                    .frame(height: 700)

                StockTickerView(chartVM: chartVM, quoteVM: loadingStubsQuoteVM)
                    .previewDisplayName("Loading Quote")
                    .frame(height: 700)

                StockTickerView(chartVM: chartVM, quoteVM: errorStubsQuoteVM)
                    .previewDisplayName("Error Quote")
                    .frame(height: 700)
            }.previewLayout(.sizeThatFits)
        }}