//
//  PhotoAlbumViewController+FlickrClient.swift
//  Virtual Tourist
//
//  Created by Luk, Alex on 6/15/18.
//  Copyright © 2018 Udacity. All rights reserved.
//
import Foundation

extension PhotoAlbumViewController {
    internal func fetchResultsFromFlickr() {
        let _ = self.flickrClient.getResultsFromFlickr(pin: self.pin, withPageNumber:1) { (photosDictionary, error) in
            if let photosDictionary = photosDictionary {
                
                if let totalResults = photosDictionary[FlickrConstants.ResponseKeys.Total] {
                    self.pin.totalResults = Int32(totalResults as! String)!
                    try? self.dataController.viewContext.save()
                } else {
                    return
                }
                guard let photos = photosDictionary[FlickrConstants.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                    return
                }
                if self.pin.totalResults <= Constants.PhotoAlbum.maxPhotosToDisplay {
                    self.storeAllPhotosFromResults(photos)
                    return
                }
                self.fetchAndStoreRemainingPhotosFromFlickr()
            }
        }
    }
    
    private func fetchAndStoreResultsFromFlickrWithPagesMappedToIndexes(_ pagesMappedToRandomPhotoIndexes: [Int: [Int]]) {
        for (key, value) in pagesMappedToRandomPhotoIndexes {
            fetchAndStoreSpecificPhotos(key, indexesOfPhoto: value)
        }
    }
    
    private func fetchAndStoreSpecificPhotos(_ pageNumber:Int, indexesOfPhoto: [Int]) {
        let _ = self.flickrClient.getResultsFromFlickr(pin: self.pin, withPageNumber:pageNumber ) { (photosDictionary, error) in
            if let photosDictionary = photosDictionary {
                guard let photos = photosDictionary[FlickrConstants.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                    return
                }
                guard !photos.isEmpty else {
                    return
                }
                self.storeSpecificPhotos(photos, indexesOfPhoto: indexesOfPhoto)
            }
        }
    }
    
    private func fetchAndStoreRemainingPhotosFromFlickr() {
        let numAlreadyStoredPhotos = self.pin.photos == nil ? 0 : self.pin.photos!.count
        let numResultsToDisplay = Int(min(Int(self.pin.totalResults), FlickrConstants.APIProperties.MaximumResults))
        let numResultsToFetch = numResultsToDisplay - numAlreadyStoredPhotos
        
        let pagesMappedToRandomPhotoIndexes = self.generatePagesMappedToRandomPhotoIndexes(forLowerBound: 1, andUpperBound: numResultsToFetch, andNumNumbers: Constants.PhotoAlbum.maxPhotosToDisplay)
        self.fetchAndStoreResultsFromFlickrWithPagesMappedToIndexes(pagesMappedToRandomPhotoIndexes)
    }
    
    private func generateRandomNumber(between lower: Int, and upper: Int) -> Int {
        return Int(arc4random_uniform(UInt32(upper - lower))) + lower
    }
    
    private func generatePagesMappedToRandomPhotoIndexes(forLowerBound lower: Int, andUpperBound upper:Int, andNumNumbers iterations: Int) -> [Int : [Int]] {
        
        guard iterations <= (upper - lower) else {
            return [:]
        }
        
        var numbersSet: Set<Int> = Set<Int>()
        var numbers = [Int: [Int]]()
        
        (0..<iterations).forEach { _ in
            let beforeCount = numbersSet.count
            repeat {
                let randomNum = generateRandomNumber(between: lower, and: upper)
                let page = Int((randomNum - 1) / FlickrConstants.ParameterValues.PerPage) + 1
                numbersSet.insert(randomNum)
                if (numbersSet.count != beforeCount) {
                    if numbers[page] == nil {
                        numbers[page] = [Int]()
                    }
                    numbers[page]!.append((randomNum - 1) % FlickrConstants.ParameterValues.PerPage)
                }
            } while numbersSet.count == beforeCount
        }
        return numbers
    }
}
