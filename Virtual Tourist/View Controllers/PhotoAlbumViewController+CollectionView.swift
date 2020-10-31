//
//  PhotoAlbumViewController+CollectionView.swift
//  Virtual Tourist
//
//  Created by Luk, Alex on 6/15/18.
//  Copyright © 2018 Udacity. All rights reserved.
//
import UIKit

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let currentIndex = (indexPath as NSIndexPath).row
        let photo = getPhotoToDisplay(currentIndex)
        
        updateCell(photo: photo, cell: cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        photosToDisplay.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        
        dataController?.backgroundContext.perform {
            self.deletePhoto(cell.imageUrl!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellLength = getCellLength(collectionView)
        return CGSize(width: cellLength, height: cellLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    private func updateCell(photo:PhotoDataWrapper, cell:PhotoCell) {
        cell.imageView.image = photo.image
        cell.imageUrl = photo.imageUrl
        cell.imageView.layer.borderWidth = Constants.PhotoAlbum.cellBorderWidth
        cell.imageView.alpha = cell.imageUrl == nil ? Constants.PhotoAlbum.cellAlphaWhenLoading : Constants.PhotoAlbum.cellAlphaWhenLoaded
        if cell.imageUrl == nil {
            cell.imageView.addSubview(buildCellActivityIndicator(collectionView))
        }
    }
    
    private func getPhotoToDisplay(_ index:Int) -> PhotoDataWrapper {
        if (self.photosToDisplay.count < index) {
            return buildDummyPhotoDataWrapper()
        }
        return self.photosToDisplay[index]
    }
    
    private func buildCellActivityIndicator(_ collectionView: UICollectionView) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        let cellLength = getCellLength(collectionView)
        activityIndicator.center = CGPoint(x: cellLength/2, y: cellLength/2)
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    private func getCellLength(_ collectionView: UICollectionView) -> Double {
        let extraSpacing = Constants.PhotoAlbum.cellsPerRow - 1
        return (Double(collectionView.bounds.width) - extraSpacing ) / Constants.PhotoAlbum.cellsPerRow
    }
}

