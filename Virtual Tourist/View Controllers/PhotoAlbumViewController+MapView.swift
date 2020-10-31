//
//  PhotoAlbumViewController+MapView.swift
//  Virtual Tourist
//
//  Created by Luk, Alex on 6/15/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import MapKit

extension PhotoAlbumViewController {
    internal func updateMap() {
        let coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        setRegionOfMapView(coordinate)
        addAnnotationToMap(coordinate)
    }
    
    internal func addAnnotationToMap(_ coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView?.addAnnotation(annotation)
    }
    
    internal func setRegionOfMapView(_ coordinate: CLLocationCoordinate2D) {
        let scalingFactor = getScalingFactor(coordinate.latitude)
        let span = getSpan(Constants.PhotoAlbum.radiusOfMapView, scalingFactor)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView?.setRegion(region, animated: true)
    }
    
    internal func getScalingFactor(_ latitude: Double) -> Double {
        let degreesOfCircle = 360.0
        return abs((cos(2 * Double.pi * latitude / degreesOfCircle)))
    }
    
    internal func getSpan(_ miles: Double, _ scalingFactor: Double) -> MKCoordinateSpan{
        let milesPerSixtyNauticalMiles = 69.0
        return MKCoordinateSpanMake(miles / milesPerSixtyNauticalMiles, miles / (scalingFactor * milesPerSixtyNauticalMiles))
    }
    
}
