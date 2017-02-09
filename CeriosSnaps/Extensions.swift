//
//  Extensions.swift
//  CeriosSnaps
//
//  Created by Rey Cerio on 2017-02-05.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImageWithUrl(imageUrlString: String){
        
        let url = NSURL(string: imageUrlString)
        URLSession.shared.dataTask(with: url as! URL) { (data, response, error) in
            if error != nil {
                print("Could not load image: ", error ?? "error unknown")
                return
            }
            //bring it back to main queue
            DispatchQueue.main.async(execute: {
                guard let downloadData = data else {return}
                if let downloadImageData = UIImage(data: downloadData) {
                    self.image = downloadImageData
                }
            })
        }.resume()
        
    }
    
}

extension UIView {
    func addConstraintsWithVisualFormat(format: String, views: UIView...) {
        var viewDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewDictionary))
    }
}

