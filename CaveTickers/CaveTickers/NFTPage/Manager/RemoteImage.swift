//
//  RemoteImage.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/5.
//

import SwiftUI
import Foundation

// MARK: - Custom image view class to load images from web
@MainActor
struct RemoteImage: View {
    @ObservedObject var assetModel: AssetModel

    // MARK: - Main rendering function
    public var body: some View {
            let placeholder = UIImage(named: "placeholder")!
            return Image(uiImage: assetModel.image ?? placeholder)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .onAppear {
                    assetModel.fetchAsset()
                }
        }
}

// MARK: - Custom image observable object
@MainActor
class AssetModel: ObservableObject {
    /// Dynamic properties that the UI will react to
    @Published var image: UIImage?

    /// Init with a certain model
    private var imageLocation: String = ""
    init(model: NFTAssetModel, thumbnail: Bool = true, collectionImage: Bool = false) {
        if collectionImage {
            imageLocation = model.collection.largeImageUrl
        } else {
            imageLocation = thumbnail ? model.imageThumbnailURL : model.imageURL
        }
    }


    /// Fetch image asset
    func fetchAsset() {
        if image == nil {
            if let documentsImage = loadImageFromDocumentDirectory(fileName: imageLocation) {
                image = documentsImage
            } else {
                if let imageUrl = URL(string: imageLocation) {
                    URLSession.shared.dataTask(with: imageUrl) { (data, _, _) in
                        DispatchQueue.main.async {
                            if let imageData = data, let downloadedImage = UIImage(data: imageData) {
                                self.saveImageInDocumentDirectory(image: downloadedImage, fileName: self.imageLocation)
                                self.image = downloadedImage
                            } else {
                                print("\nNFT Image Failed: \(self.imageLocation)\n")
                                self.image = UIImage(named: "placeholder")!
                            }
                        }
                    }
                    .resume()
                } else {
                    DispatchQueue.main.async {
                        self.image = UIImage(named: "placeholder")!
                    }
                }
            }
        }
    }

    private func saveImageInDocumentDirectory(image: UIImage, fileName: String) {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsUrl.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "_"))
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
        }
    }

    public func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsUrl.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "_"))
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {}
        return nil
    }
}
