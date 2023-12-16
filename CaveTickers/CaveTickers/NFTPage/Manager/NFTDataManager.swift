//
//  NFTDataManager.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI
import Foundation

class NFTDataManager: NSObject, ObservableObject {
    /// Dynamic properties that the UI will react to
    @Published var lastSoldNFTItems: [NFTAssetModel] = []
    @Published var newReleasedNFTItems: [NFTAssetModel] = []
    @Published var holdingNFTItems: [NFTAssetModel] = []
    @Published var favoriteNFTItems: [NFTAssetModel] = []
    @Published var assetStats: [String: NFTAssetStatsModel] = [:]
    @Published var collections: [NFTCollection: NFTAssetModel] = [:]
    @Published var selectedCollectionItems: [NFTCollection: [NFTAssetModel]] = [:]
    @Published var selectedCollection: NFTCollection = .blockart
    @Published var selectedNFTItem: NFTAssetModel?

    /// Default init method
    override init() {
        super.init()
        fetchFavoriteNFTs()
    }

    /// Check if the user has this item into the favorites list
    var isSelectedItemFavorite: Bool {
        favoriteNFTItems.contains { $0.id == selectedNFTItem?.id }
    }

    /// Add or Remove the selected item to the favorites list
    func favoriteSelectedItemIfNeeded() {
        if isSelectedItemFavorite {
            favoriteNFTItems.removeAll { $0.id == selectedNFTItem?.id }
        } else {
            guard let selectedItem = selectedNFTItem else { return }
            favoriteNFTItems.append(selectedItem)
        }
        let favoriteItems = favoriteNFTItems.compactMap { $0.dictionary }
        UserDefaults.standard.setValue(favoriteItems, forKey: "favoriteItems")
        UserDefaults.standard.synchronize()
    }

    /// Get the price for a NFT asset
    /// - Parameter asset: asset to get the price for
    /// - Returns: returns formatted price
    func price(forAsset asset: NFTAssetModel) -> String {
        let defaultPrice = "- -"
        guard let stats = assetStats[asset.tokenID] else {
            fetchAssetStats(asset: asset)
            return defaultPrice
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        /// Get the last sale price if available
        if let lastSale = stats.lastSale, let salePrice = Double(lastSale.totalPrice ?? "") {
            if let price = formatter.string(from: NSNumber(value: salePrice / 1000000000000000000)) {
                return "\(price) ETH"
            }
        }

        /// Get the floor and one day average price
        let floorPrice = stats.stats?.floorPrice ?? 0.0
        let oneDayAveragePrice = stats.stats?.oneDayAveragePrice ?? 0
        guard let price = formatter.string(from: NSNumber(value: max(floorPrice, Double(oneDayAveragePrice)))) else {
            return defaultPrice
        }
        return "\(price) ETH"
    }

    /// Fetch favorite nfts from user defaults
    private func fetchFavoriteNFTs() {
        if let favoriteItems = UserDefaults.standard.array(forKey: "favoriteItems") as? [[String: Any]] {
            var favoriteNFTs: [NFTAssetModel] = []
            favoriteItems.forEach { dictionary in
                if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed) {
                    if let model = try? JSONDecoder().decode(NFTAssetModel.self, from: data) {
                        favoriteNFTs.append(model)
                    }
                }
            }
            favoriteNFTItems = favoriteNFTs
        }
    }

    func generateMockHoldingNFTItems() {
        let demoAssetModels = [
            NFTAssetModel(
                id: 0,
                tokenID: "12283743",
                salesCount: 0,
                imageURL: "https://millersmusic.co.uk/cdn/shop/articles/Blog_Image_40.png?v=1681389491",
                imageThumbnailURL: "https://millersmusic.co.uk/cdn/shop/articles/Blog_Image_40.png?v=1681389491",
                name: "Deem19283763",
                nftAssetDescription: AssetDescription(itemDescription: "This is the first demo NFT description"),
                assetContract: AssetContract(address: "0x123456789"),
                permalink: "https://example.com/nft/123",
                collection: AssetCollection(largeImageUrl: "https://millersmusic.co.uk/cdn/shop/articles/Blog_Image_40.png?v=1681389491"),
                creator: Creator(user: User(username: "Deem32432"))
            ),
            NFTAssetModel(
                id: 1,
                tokenID: "459376",
                salesCount: 1,
                imageURL: "https://memeprod.ap-south-1.linodeobjects.com/user-template/976f753dd3aeb849408933e322b85973.png",
                imageThumbnailURL: "https://memeprod.ap-south-1.linodeobjects.com/user-template/976f753dd3aeb849408933e322b85973.png",
                name: "DEEM3928437",
                nftAssetDescription: AssetDescription(itemDescription: "This is the second demo NFT description"),
                assetContract: AssetContract(address: "0x987654321"),
                permalink: "https://example.com/nft/456",
                collection: AssetCollection(largeImageUrl: "https://memeprod.ap-south-1.linodeobjects.com/user-template/976f753dd3aeb849408933e322b85973.png"),
                creator: Creator(user: User(username: "Deem32432"))
            )
        ]
        holdingNFTItems = demoAssetModels
    }
}

// MARK: - Fetch NFT assets
extension NFTDataManager {
    /// Fetch last sold nft items
    func fetchLastSoldItems() {
        let requestParams = AssetsRequestParameters(filter: .lastSold, collection: nil)
        guard let requestURL = requestParams.requestURL else { return }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
        URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            self.parseData(data, lastSoldItems: true)
        }
        .resume()
    }

    /// Fetch latest nft items
    func fetchNewReleasedItems() {
        let requestParams = AssetsRequestParameters(filter: .new, collection: nil)
        guard let requestURL = requestParams.requestURL else { return }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
        URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            self.parseData(data, lastSoldItems: false)
        }
        .resume()
    }

    func fetchHoldingItems() {
        let requestParams = AssetsRequestParameters(filter: .new, collection: nil)
        guard let requestURL = requestParams.requestURL else { return }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
        URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            self.parseData(data, lastSoldItems: false)
        }
        .resume()
    }

    /// Fetch collections
    func fetchCollections() {
        var allCollections = NFTCollection.allCases
        func fetchCollectionAssets() {
            if let collection = allCollections.first {
                allCollections.removeFirst()
                fetchAssets(forCollection: collection, limit: 10) { models in
                    if let firstModel = models.first {
                        self.collections[collection] = firstModel
                    }
                    fetchCollectionAssets()
                }
            }
        }
        fetchCollectionAssets()
    }

    /// Fetch items for selected collection
    func fetchSelectedCollectionItems() {
        fetchAssets(forCollection: selectedCollection) { items in
            self.selectedCollectionItems[self.selectedCollection] = items
        }
    }

    /// Fetch price stats for an item
    /// - Parameters:
    ///   - asset: nft asset item
    func fetchAssetStats(asset: NFTAssetModel) {
        let requestParams = AssetStatsRequestParameters(address: asset.assetContract.address, token: asset.tokenID)
        guard let requestURL = requestParams.requestURL else { return }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
        URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            guard let jsonData = data else { return }
            guard let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) else { return }
            guard let stats = ((dictionary as? [String: Any])?["collection"] as? [String: Any]) else { return }
            var statsDictionary: [String: Any] = [:]
            statsDictionary["last_sale"] = (dictionary as? [String: Any])?["last_sale"]
            statsDictionary["stats"] = stats
            var statsModel = NFTAssetStatsModel(stats: Stats(oneDayAveragePrice: nil, floorPrice: 0.0), lastSale: nil)
            if let statsData = try? JSONSerialization.data(withJSONObject: statsDictionary, options: .prettyPrinted) {
                if let model = try? JSONDecoder().decode(NFTAssetStatsModel.self, from: statsData) {
                    statsModel = model
                }
            }
            DispatchQueue.main.async {
                self.assetStats[asset.tokenID] = statsModel
            }
        }
    .resume()
    }
    func fetchAssetsForOwner(ownerAddress: String) {
        let requestParams = OwnerAssetsRequestParameters(ownerAddress: ownerAddress)
        guard let requestURL = requestParams.requestURL else { return }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            guard let self = self, error == nil, let data = data else {
                print(error ?? "Unknown error")
                return
            }
            self.parseData(data, lastSoldItems: false) { models in
                DispatchQueue.main.async {
                    self.holdingNFTItems = models
                }
            }
        }
        .resume()
    }
    /// Parse fetched data from the API
    /// - Parameters:
    ///   - data: data from API response
    ///   - lastSoldItems: indicates if this data should be assigned to the last sold items array or to the new released items
    private func parseData(_ data: Data?, lastSoldItems: Bool, completion: ((_ items: [NFTAssetModel]) -> Void)? = nil) {
        guard let jsonData = data else { return }
        guard let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) else { return }
        guard let assets = (dictionary as? [String: Any])?["assets"] as? [[String: Any]] else { return }
        var nftAssetsArray: [NFTAssetModel] = []
        assets.forEach { assetDictionary in
            if let assetData = try? JSONSerialization.data(withJSONObject: assetDictionary, options: .prettyPrinted) {
                if let assetModel = try? JSONDecoder().decode(NFTAssetModel.self, from: assetData),
                !assetModel.imageURL.contains(".mp4") && !assetModel.imageURL.contains(".svg") {
                    nftAssetsArray.append(assetModel)
                }
            }
        }
        DispatchQueue.main.async {
            if completion != nil {
                completion?(nftAssetsArray)
            } else {
                if lastSoldItems { self.lastSoldNFTItems = nftAssetsArray } else {
                    self.newReleasedNFTItems = nftAssetsArray
                }
            }
        }
    }

    /// Fetch assets for a given collection
    /// - Parameters:
    ///   - collection: collection
    ///   - completion: returns an array of assets
    private func fetchAssets(
        forCollection collection: NFTCollection,
        limit: Int = 20,
        completion: @escaping (_ models: [NFTAssetModel]) -> Void
    ) {
        let requestParams = AssetsRequestParameters(filter: .new, collection: collection, limit: limit)
        guard let requestURL = requestParams.requestURL else { return }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
        URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            DispatchQueue.main.async {
                guard let jsonData = data else { return }
                guard let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) else { return }
                guard let assets = (dictionary as? [String: Any])?["assets"] as? [[String: Any]] else { return }
                var collectionAssets: [NFTAssetModel] = []
                assets.forEach { assetDictionary in
                    if let assetData = try? JSONSerialization.data(withJSONObject: assetDictionary, options: .prettyPrinted) {
                        if let assetModel = try? JSONDecoder().decode(NFTAssetModel.self, from: assetData),
                        !assetModel.imageURL.contains(".mp4") && !assetModel.imageURL.contains(".svg") {
                            collectionAssets.append(assetModel)
                        }
                    }
                }
                completion(collectionAssets)
            }
        }
        .resume()
    }
}

// MARK: - Widget APIs
extension NFTDataManager {
    func fetchLastSoldNFT(completion: @escaping (_ models: [NFTAssetModel]) -> Void) {
        let requestParams = AssetsRequestParameters(filter: .lastSold, collection: nil)
        guard let requestURL = requestParams.requestURL else { return }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
        URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            self.parseData(data, lastSoldItems: true, completion: completion)
        }
        .resume()
    }
}

// MARK: - Array Extension to allow AppStorage to store arrays
extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(
            [Element].self,
                from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
            let result = String(
                data: data,
                encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
