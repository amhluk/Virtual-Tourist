//
//  PhotoAlbumViewController+UpdateUI.swift
//  Virtual Tourist
//
//  Created by Luk, Alex on 6/15/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

extension PhotoAlbumViewController {
    internal func updateUIWhenLoading() {
        DispatchQueue.main.async {
            self.newCollectionButton.isEnabled = false
            self.collectionView.isUserInteractionEnabled = false
            self.collectionView.addSubview(self.loadingOverlayView)
        }
    }
    
    internal func restoreUIWhenFinishLoading() {
        DispatchQueue.main.async {
            self.newCollectionButton.isEnabled = true
            self.collectionView.isUserInteractionEnabled = true
            self.loadingOverlayView.removeFromSuperview()
        }
    }
    
    internal func disableMapViewUserInteraction() {
        DispatchQueue.main.async {
            self.mapView.isZoomEnabled = false
            self.mapView.isRotateEnabled = false
            self.mapView.isScrollEnabled = false
        }
    }
    
    internal func updateUIForCollectionView() {
        DispatchQueue.main.async {
            let noResults = self.pin.totalResults == 0
            let noImagesShown = noResults || (self.pin.totalResults != -1 && self.photosToDisplay.count == 0)
            self.noImagesAvailableLabel.isHidden = !noImagesShown
            self.collectionView.backgroundColor = noImagesShown ? Constants.PhotoAlbum.noImagesBackgroundColor : Constants.PhotoAlbum.showImagesBackgroundColor
            self.collectionView.reloadData()
        }
    }
    
    internal func setupLoadingOverlayView() {
        DispatchQueue.main.async {
            self.loadingOverlayView.backgroundColor = Constants.PhotoAlbum.overlayBackgroundColor
            self.loadingOverlayView.frame = self.collectionView.bounds
            self.loadingOverlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.mapViewActivityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.mapViewActivityIndicator.center = CGPoint(x:self.loadingOverlayView.bounds.width/2, y:self.loadingOverlayView.bounds.height/2)
            self.mapViewActivityIndicator.startAnimating()
            
            self.loadingOverlayView.addSubview(self.mapViewActivityIndicator)
        }
    }
}
