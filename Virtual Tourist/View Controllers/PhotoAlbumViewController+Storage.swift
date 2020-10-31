//
//  PhotoAlbumViewController+Storage.swift
//  Virtual Tourist
//
//  Created by Luk, Alex on 6/15/18.
//  Copyright © 2018 Udacity. All rights reserved.
//
import CoreData

extension PhotoAlbumViewController {
    internal func storeAllPhotosFromResults(_ photos: [[String : AnyObject]]) {
        for photo in photos {
            storePhoto(photo)
        }
    }
    
    internal func storeSpecificPhotos(_ photos: [[String : AnyObject]], indexesOfPhoto: [Int]) {
        for index in indexesOfPhoto {
            guard photos.count > index else {
                continue
            }
            let photo = photos[index]
            storePhoto(photo)
        }
    }
    
    private func storePhoto(_ photo: [String: AnyObject]) {
        let photoObject = Photo(context: self.dataController.viewContext)
        photoObject.pin = self.pin
        if let imageURLString = photo[FlickrConstants.ResponseKeys.MediumURL] as? String {
            photoObject.imageUrl = imageURLString
            photoObject.image = try? Data(contentsOf: URL(string: imageURLString)!)
        }
        try? self.dataController.viewContext.save()
    }
    
    internal func deletePhoto(_ imageUrl: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        request.predicate = NSPredicate(format:"imageUrl = %@", imageUrl)
        request.returnsObjectsAsFaults = false
        
        guard let result = try? self.dataController.viewContext.fetch(request) as! [NSManagedObject] else {
            return
        }
        
        guard !result.isEmpty else {
            return
        }
        
        self.dataController.viewContext.delete(result.first!)
        
        try? self.dataController.viewContext.save()
    }
    
    internal func deleteAllPhotos() {
        for photo in self.pin.photos! {
            self.dataController.viewContext.delete(photo as!NSManagedObject)
        }
        self.pin.areResultsLoaded = false
        self.pin.totalResults = -1
        try? self.dataController.viewContext.save()
    }
}
