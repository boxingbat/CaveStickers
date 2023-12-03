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

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("MetaSwiftUI")
                .font(.title)

            Text("Status: \(metaMaskRepo.connectionStatus)")
                .fontWeight(.bold)

            Text("Chain ID: \(metaMaskRepo.chainID)")
                .fontWeight(.bold)

            Text("Account: \(metaMaskRepo.ethAddress)")
                .fontWeight(.bold)

            Button {
                metaMaskRepo.connectToDapp()
            } label: {
                Text("Connect to MetaMask")
                    .frame(width: 300, height: 40)
            }
            .buttonStyle(.borderedProminent)

            Text("Balance: \(metaMaskRepo.balance)")
                .fontWeight(.bold)

            Button {
                metaMaskRepo.getBalance()
            } label: {
                Text("Get account balance")
                    .frame(width: 300, height: 40)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .Connection)) { notification in
            status = notification.userInfo?["value"] as? String ?? "Offline"
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WalletHomeView()
    }
}
