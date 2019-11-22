//
//  ImageDownloader.swift
//  Health
//
//  Created by Vikhyath on 24/10/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader {
    
    static let imageCache = NSCache<NSString, UIImage>()
    
    static func downloadImage(urlString: String, completion: @escaping (_ image: UIImage?, _ error: Error? ) -> Void) {
        guard let url = URL(string: urlString) else { return }
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage, nil)
        } else {
            guard let imageUrl = url as URL? else { return }
            let urlRequest = URLRequest(url: imageUrl)
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                
                if error != nil {
                    return
                }
                
                if let error = error {
                    completion(nil, error)
                    
                } else if let data = data, let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    completion(image, nil)
                } else {
                    completion(nil, error)
                }
            }
            task.resume()
        }
    }
}
