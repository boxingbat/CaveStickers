//
//  WebSocketManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/22.
//

import Foundation

class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
    private var webSocket: URLSessionWebSocketTask?
    var onReceive: ((String) -> Void)?
    private var symbol: String?

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
        webSocket?.send(message, completionHandler: { error in
            if let error = error {
                print("send error : \(error)")
            }
        })
    }
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
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
            self?.receive() // Continue receiving messages
        })
    }
    private func handleReceivedData(_ data: Data) {
        do {
            let stockInfo = try JSONDecoder().decode(WebsocketStockInfo.self, from: data)
            if let firstPriceData = stockInfo.data.first {
                let displayString = "\(firstPriceData.symbolData): \(firstPriceData.priceData)"
                print("\(displayString)")
                onReceive?(String(firstPriceData.priceData))
            }
        } catch {
            print("JSON decode error: \(error)")
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
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected")
        ping()
        receive()
        if let symbol = self.symbol {
            send(symbol: symbol)
        }
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket disconnected")
    }
}
