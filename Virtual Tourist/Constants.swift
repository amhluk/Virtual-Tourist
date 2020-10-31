//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Luk, Alex on 5/2/18.
//  Copyright © 2018 Udacity. All rights reserved.
//
import UIKit

struct Constants {
    
    // MARK: User Defaults
    struct UserDefaults {
        static let HasLaunchedBefore = "hasLaunchedBefore"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let LatitudeDelta = "latitudeDelta"
        static let LongitudeDelta = "longitudeDelta"
    }
    
    // MARK: PhotoAlbum
    struct PhotoAlbum {
        static let maxPhotosToDisplay = 40
        static let radiusOfMapView = 5.0
        static let noImagesBackgroundColor = UIColor.lightGray
        static let showImagesBackgroundColor = UIColor.white
        static let cellsPerRow = 4.0
        static let cellAlphaWhenLoading:CGFloat = 0.5
        static let cellAlphaWhenLoaded:CGFloat = 1.0
        static let cellBorderWidth:CGFloat = 0.25
        static let overlayBackgroundColor = UIColor(white: 0, alpha: 0.5)
    }
}

