//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Luk, Alex on 5/2/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var pins: [Pin] = []
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    var draggableAnnotation: MKPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpFetchedResultsController()
        restorePreviousSettingsToMap()
        addLongPressGestureRecognizer()
    }
    
    private func setUpFetchedResultsController() {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: buildFetchRequestForPin(), managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func reloadPins() {
        if let result = try? dataController.viewContext.fetch(buildFetchRequestForPin()) {
            pins = result
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(buildAnnotationsFromPins())
    }
    
    private func buildAnnotationsFromPins() -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        for pin in pins {
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            annotations.append(buildAnnotationWithProperties(coordinate: coordinate))
        }
        return annotations;
    }
    
    private func buildAnnotationWithProperties(coordinate: CLLocationCoordinate2D) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
    
    private func buildFetchRequestForPin() -> NSFetchRequest<Pin>{
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest;
    }

    private func restorePreviousSettingsToMap() {
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.HasLaunchedBefore) {
            UserDefaults.standard.set(true, forKey: Constants.UserDefaults.HasLaunchedBefore)
            saveMapRegion()
            return
        }
        setMapRegion(center: getCenterFromUserDefaults(), span: getSpanFromuserDefaults())
        reloadPins()
    }
    
    private func setMapRegion(center: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func getCenterFromUserDefaults() -> CLLocationCoordinate2D {
        let latitude = UserDefaults.standard.double(forKey: Constants.UserDefaults.Latitude)
        let longitude = UserDefaults.standard.double(forKey: Constants.UserDefaults.Longitude)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    private func getSpanFromuserDefaults() -> MKCoordinateSpan {
        let latitudeDelta = UserDefaults.standard.double(forKey: Constants.UserDefaults.LatitudeDelta)
        let longitudeDelta = UserDefaults.standard.double(forKey: Constants.UserDefaults.LongitudeDelta)
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    private func addLongPressGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        self.mapView.addGestureRecognizer(longPressGesture)
    }
    
    @objc
    private func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        let coordinate = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)

        if gesture.state == UIGestureRecognizerState.began {
            draggableAnnotation = buildAnnotationWithProperties(coordinate: coordinate)
            mapView.addAnnotation(draggableAnnotation)
        } else if gesture.state == UIGestureRecognizerState.ended {
            saveAnnotation(coordinate: draggableAnnotation.coordinate)
            draggableAnnotation = nil
        } else if draggableAnnotation != nil {
            draggableAnnotation.coordinate = coordinate
        }
    }
    
    private func saveAnnotation(coordinate: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        try? dataController.viewContext.save()
        
        if let result = try? dataController.viewContext.fetch(buildFetchRequestForPin()) {
            pins = result
        }
    }
}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        return  MKPinAnnotationView(annotation: annotation, reuseIdentifier: "draggableAnnotation")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let coordinate = view.annotation?.coordinate {
            let selectedPin = findPin(coordinate: coordinate)
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            controller.pin = selectedPin
            controller.dataController = dataController
            self.present(controller, animated: true, completion: nil)
        }
        
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
    
    private func findPin(coordinate: CLLocationCoordinate2D?) -> Pin? {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "latitude == %@ && longitude == %@", argumentArray: [coordinate!.latitude, coordinate!.longitude])
        fetchRequest.predicate = predicate
        
        var selectedPins = [Pin]()
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            selectedPins = result
        }
        
        return selectedPins.count > 0 ? selectedPins.first : nil
    }
    
    private func saveMapRegion() {
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: Constants.UserDefaults.Latitude)
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: Constants.UserDefaults.Longitude)
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: Constants.UserDefaults.LatitudeDelta)
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: Constants.UserDefaults.LongitudeDelta)
    }
}
