//
//  NFTModel.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//
import Foundation

// MARK: - NFTAssetModel
struct NFTAssetModel: Codable {
    let id: Int
    let tokenID: String
    let salesCount: Int
    let imageURL, imageThumbnailURL: String
    let name: String
    let nftAssetDescription: AssetDescription
    let assetContract: AssetContract
    let permalink: String
    let collection: AssetCollection
    let creator: Creator?

    enum CodingKeys: String, CodingKey {
        case id, name, collection, permalink, creator
        case tokenID = "token_id"
        case salesCount = "num_sales"
        case imageURL = "image_url"
        case imageThumbnailURL = "image_thumbnail_url"
        case nftAssetDescription = "description"
        case assetContract = "asset_contract"
    }
}

// MARK: - Asset Description
class AssetDescription: Codable {
    let itemDescription: String

    enum CodingKeys: String, CodingKey {
        case itemDescription = "description"
    }

    required public init(from decoder: Decoder) throws {
        do {
            let value = try decoder.singleValueContainer()
            itemDescription = try value.decode(String.self)
        } catch {
            itemDescription = "Missing Description"
        }
    }

    init(itemDescription: String) {
        self.itemDescription = itemDescription
    }
}

// MARK: - AssetCollection
struct AssetCollection: Codable {
    let largeImageUrl: String

    enum CodingKeys: String, CodingKey {
        case largeImageUrl = "large_image_url"
    }
}

// MARK: - AssetContract
struct AssetContract: Codable {
    let address: String
}

// MARK: - Creator
struct Creator: Codable {
    let user: User

    enum CodingKeys: String, CodingKey {
        case user
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decodeIfPresent(User.self, forKey: .user) ?? User(username: "unnamed")
    }

    init(user: User) {
        self.user = user
    }
}

// MARK: - User
struct User: Codable {
    let username: String

    enum CodingKeys: String, CodingKey {
        case username
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decodeIfPresent(String.self, forKey: .username) ?? "unnamed"
    }

    init(username: String) {
        self.username = username
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

// MARK: - Demo Asset Model
let demoAssetModel = NFTAssetModel(id: 0, tokenID: "123", salesCount: 0, imageURL: "", imageThumbnailURL: "", name: "", nftAssetDescription: AssetDescription(itemDescription: ""), assetContract: AssetContract(address: ""), permalink: "", collection: AssetCollection(largeImageUrl: ""), creator: Creator(user: User(username: "demo user")))
