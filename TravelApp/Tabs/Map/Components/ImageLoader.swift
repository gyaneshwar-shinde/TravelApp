//
//  ImageLoader.swift
//  TravelApp
//
//  Created by Laptop X on 24/05/26.
//


//
//  ImageLoader.swift
//  TravelApp
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.urlCache = URLCache(memoryCapacity: 16 * 1024 * 1024,
                                   diskCapacity: 64 * 1024 * 1024)
        return URLSession(configuration: config)
    }()

    @discardableResult
    func loadImage(from urlString: String,
                   completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        let key = urlString as NSString
        if let cached = cache.object(forKey: key) {
            completion(cached)
            return nil
        }
        guard let url = URL(string: urlString) else {
            completion(nil)
            return nil
        }
        let task = session.dataTask(with: url) { [weak self] data, _, error in
            if (error as NSError?)?.code == NSURLErrorCancelled { return }
            guard let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self?.cache.setObject(image, forKey: key)
            DispatchQueue.main.async { completion(image) }
        }
        task.resume()
        return task
    }
}