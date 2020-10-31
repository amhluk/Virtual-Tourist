//
//  PhotoDataWrapper.swift
//  Virtual Tourist
//
//  Created by Luk, Alex on 6/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class PhotoDataWrapper {
    let image: UIImage
    let imageUrl: String?
    
    init(_ image: UIImage, imageUrl: String?) {
        self.image = image
        self.imageUrl = imageUrl
    }
}
