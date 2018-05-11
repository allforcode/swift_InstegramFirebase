//
//  CustomImageView.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 1/04/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    static let imageCache = NSCache<NSString, UIImage>()
    
    func loadImage(urlString: String, completion: (() -> Void)? = nil ) {
        
        self.image = nil
        
        if let imageFromCache = CustomImageView.imageCache.object(forKey: NSString(string: urlString)) {
            DispatchQueue.main.async {
                self.image = imageFromCache
            }
        } else {
            guard let url = URL(string: urlString) else { return }

            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let err = error {
                    print("failed to download image", err)
                    return
                }
                
                //to prevent multiple loading, it probably doesn't need in swfit 4
                if url.absoluteString != urlString {
                    print("url string not equal in CustomImageView:24")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else { return }
                
                if httpResponse.statusCode == 200 {
                    guard let imageData = data else { return }
                    
                    DispatchQueue.main.async {
                        guard let image = UIImage(data: imageData) else { return }
                        self.image = image
                        if let completion = completion {
                            completion()
                        }
                        CustomImageView.imageCache.setObject(image, forKey: NSString(string: url.absoluteString))
                    }
                }else {
                    print(httpResponse)
                    return
                }
                
            }).resume()
        }
    }
}