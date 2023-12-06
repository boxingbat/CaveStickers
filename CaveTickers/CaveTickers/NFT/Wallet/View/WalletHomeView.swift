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
        VStack(alignment: .leading, spacing: 16) {
            Text("\(metaMaskRepo.connectionStatus)")
                .fontWeight(.bold)

            Text("Chain ID: \(metaMaskRepo.chainID)")
                .fontWeight(.bold)

            Text("Account: \(metaMaskRepo.ethAddress)")
                .fontWeight(.bold)

            Text("Balance: \(metaMaskRepo.balance)")
                .fontWeight(.bold)

            HStack {
                Button {
                    metaMaskRepo.connectToDapp()
                } label: {
                    Text("Connect")
                        .frame(width: 100, height: 40)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.secondary)

                Button {
                    metaMaskRepo.getBalance()
                } label: {
                    Text("Update")
                        .frame(width: 100, height: 40)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.secondary)

            }
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
