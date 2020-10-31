//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Luk, Alex on 5/6/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var noImagesAvailableLabel: UILabel!
    
    var photosToDisplay: [PhotoDataWrapper] = []
    var pin: Pin!
    
    var dataController:DataController!
    let flickrClient = FlickrClient()
    var saveObserverToken: Any?
    
    let loadingOverlayView = UIView()
    let mapViewActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLoadingOverlayView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSaveNotificationObserver()
        updateMap()
        disableMapViewUserInteraction()
        populatePhotosToDisplay()
    }
    
    deinit {
        removeSaveNotificationObserver()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Editing
    
    private func updateCollectionView() {
        photosToDisplay = []
        
        populateStoredPhotos()
        
        let numDummyPhotosToDisplay = pin.areResultsLoaded ? 0 : max(0, getTotalNumPhotosToDisplay() - min(40, photosToDisplay.count))
        populateDummyPhotos(numDummyPhotosToDisplay)
        
        let noMorePhotosToLoad = numDummyPhotosToDisplay == 0 && pin.totalResults != -1
        if (noMorePhotosToLoad) {
            self.restoreUIWhenFinishLoading()
            
            if (!self.pin.areResultsLoaded) {
                self.pin.areResultsLoaded = true
                try? self.dataController.viewContext.save()
            }
        }
        
        updateUIForCollectionView()
    }
    
    private func populateStoredPhotos() {
        let storedPhotos = Array(pin.photos!) as! [Photo]
        
        for photo in storedPhotos {
            guard photo.image != nil else {
                continue
            }
            let photoDataWrapper = PhotoDataWrapper(UIImage(data:photo.image!)!, imageUrl: photo.imageUrl)
            photosToDisplay.append(photoDataWrapper)
        }
    }
    
    private func populateDummyPhotos(_ numDummyPhotosToDisplay: Int) {
        guard numDummyPhotosToDisplay > 0 else {
            return
        }
        
        let dummyPhotoDataWrapper = buildDummyPhotoDataWrapper()
        for _ in 0..<numDummyPhotosToDisplay {
            photosToDisplay.append(dummyPhotoDataWrapper)
        }
    }
    
    internal func populatePhotosToDisplay() {
        let storedPhotos = Array(pin.photos!) as! [Photo]
        
        if (pin.totalResults != -1 && storedPhotos.count >= getTotalNumPhotosToDisplay() || pin.areResultsLoaded) {
            updateCollectionView()
            return
        }
        
        updateUIWhenLoading()
        
        dataController?.backgroundContext.perform {
            self.fetchResultsFromFlickr()
        }
    }
    
    private func buildNewCollection() {
        dataController?.backgroundContext.perform {
            self.deleteAllPhotos()
            self.populatePhotosToDisplay()
        }
    }
    
    internal func buildDummyPhotoDataWrapper() -> PhotoDataWrapper {
        return PhotoDataWrapper(UIImage(named: "VirtualTourist")!, imageUrl: nil)
    }
    
    private func getTotalNumPhotosToDisplay() -> Int {
        if (pin.totalResults < 1) {
            return 0
        }
        return min(Int(pin.totalResults), Constants.PhotoAlbum.maxPhotosToDisplay)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    
    @IBAction func donePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createNewCollection(_ sender: Any) {
        buildNewCollection()
    }
}

// -------------------------------------------------------------------------
// MARK: - Save Notifications

extension PhotoAlbumViewController {
    
    func addSaveNotificationObserver() {
        removeSaveNotificationObserver()
        saveObserverToken = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: dataController?.viewContext, queue: nil, using: handleSaveNotification(notification:))
    }
    
    func removeSaveNotificationObserver() {
        if let token = saveObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func handleSaveNotification(notification:Notification) {
        DispatchQueue.main.async {
            if (!self.pin.areResultsLoaded || self.photosToDisplay.count == 0) {
                self.updateCollectionView()
            }
        }
    }
}




