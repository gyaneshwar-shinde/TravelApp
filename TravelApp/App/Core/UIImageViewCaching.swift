//
//  UIImageViewCaching.swift
//  TravelApp
//
//  Created by Laptop X on 23/05/26.
//


import UIKit
import Kingfisher

extension UIImageView {
    /// Load an image via Kingfisher with a blurhash-decoded placeholder.
    /// Pass a `targetSize` to downsample large source images for thumbnail cells.
    func setRemoteImage(
        urlString: String?,
        blurhash: String?,
        targetSize: CGSize? = nil
    ) {
        let placeholder = BlurHashCache.image(for: blurhash)

        guard let urlString, let url = URL(string: urlString) else {
            image = placeholder
            return
        }

        var options: KingfisherOptionsInfo = [
            .transition(.fade(0.2)),
            .cacheOriginalImage
        ]

        if let targetSize {
            let processor = DownsamplingImageProcessor(size: targetSize)
            options.append(.processor(processor))
            options.append(.scaleFactor(UIScreen.main.scale))
        }

        kf.setImage(with: url, placeholder: placeholder, options: options)
    }

    func cancelImageLoad() {
        kf.cancelDownloadTask()
    }
}