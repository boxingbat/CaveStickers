//
//  PortfolioDataManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/30.
//

import Foundation
import CoreData

class PortfolioDataManager: ObservableObject {
    private let container: NSPersistentContainer
    private let containerName: String = "PortfolioContainer"
    private let entityName: String = "PortfolioEntity"

    @Published var savedEntities: [PortfolioEntity] = []

    init () {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error = error { print("Error loading Core Data \(error)") }
            self.getPortfolio()
        }
    }
    // MARK: - Public

    func updatedPortfolio (coin: CoinModel, amount: Double) {
        if let entity = savedEntities.first(where: { $0.coinID == coin.id }) {
            if amount > 0 {
                update(entity: entity, amount: amount)
            } else {
                delete(entity: entity)
            }
        } else {
            add(coin: coin, amount: amount)
        }
    }
    func deleteCoin (coin: CoinModel) {
        if let entity = savedEntities.first(where: { $0.coinID == coin.id }) {
            delete(entity: entity)
        }
    }
    // MARK: - Private
    private func getPortfolio () {
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching Portfolio Entities. \(error)")
        }
    }
    func isCoinInPortfolio(coinID: String) -> Bool {
        return savedEntities.contains { $0.coinID == coinID }
    }

    private func add(coin: CoinModel, amount: Double) {
        let entity = PortfolioEntity(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        applyChanges()
    }

    private func update(entity: PortfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }

    private func delete(entity: PortfolioEntity) {
        container.viewContext.delete(entity)
        applyChanges()
    }

    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving to Core Data. \(error)")
        }
    }

    private func applyChanges() {
        save()
        getPortfolio()
    }
}
