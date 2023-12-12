//
//  WebSocketManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/22.
//

import Foundation
import SwiftUI

class WebSocketManager: NSObject, URLSessionWebSocketDelegate, ObservableObject {
    private var webSocket: URLSessionWebSocketTask?
    var onReceive: ((String) -> Void)?
    private var symbol: String?
    @Published var latestPrice: String = ""
    @Published var priceChangeColor: Color = .theme.accent
    @Published var flashColor: Color = .clear

    func connect(withSymbol symbol: String) {
        self.symbol = symbol
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let url = URL(string: "wss://ws.finnhub.io?token=clau1chr01qi1291dli0clau1chr01qi1291dlig")!
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }
    func send(symbol: String) {
        let string = "{\"type\":\"subscribe\",\"symbol\":\"\(symbol)\"}"
        let message = URLSessionWebSocketTask.Message.string(string)
        webSocket?.send(message) { error in
            if let error = error {
                print("send error : \(error)")
            }
        }
    }
    func receive() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let message):
                    if let data = message.data(using: .utf8) {
                        self?.handleReceivedData(data)
                        print(data)}
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error: \(error)")
            }
            self?.receive()
        }
    }
    private func handleReceivedData(_ data: Data) {
        do {
            let stockInfo = try JSONDecoder().decode(WebsocketStockInfo.self, from: data)
            if let firstPriceData = stockInfo.data.first {
                let newPrice = firstPriceData.priceData
                let oldPrice = Double(self.latestPrice) ?? 0.0

                DispatchQueue.main.async {
                    if newPrice > oldPrice {
                        self.flashPriceChange(.themeGreen)
                    } else if newPrice < oldPrice {
                        self.flashPriceChange(.themeRed)
                    }

                    self.latestPrice = String(newPrice)
                }
            }
        } catch {
            print("JSON decode error: \(error)")
        }
    }

    private func flashPriceChange(_ color: Color) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.flashColor = color
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.flashColor = .clear
            }
        }
    }

    func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        }
    }
    func close() {
        print("Closing WebSocket connection")
        if webSocket?.state == .running {
            webSocket?.cancel(with: .goingAway, reason: "Closing connection".data(using: .utf8))
        }
        webSocket = nil
    }
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        print("WebSocket connected")
        ping()
        receive()
        if let symbol = self.symbol {
            send(symbol: symbol)
        }
    }
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        print("WebSocket disconnected")
    }
}
