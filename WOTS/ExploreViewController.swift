//
//  ExploreViewController.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 4/29/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import GoogleMaps

class ExploreViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate lazy var mapView: GMSMapView = {
        
        // Default location to CS 377U classroom
        let camera = GMSCameraPosition.camera(withLatitude: 37.43, longitude: -122.17, zoom: 17.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        return mapView
    }()
    
    var locationManager = CLLocationManager()

    // MARK: - ExploreViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup mapview
        self.view.addSubview(mapView.usingAutolayout())
        setupConstraints()
        
        // Go to current location
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Map View
        let bottomMargin = self.tabBarController?.tabBar.frame.height ?? 49.0
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -bottomMargin)
            ])
    }
    
    fileprivate func calculateDistance(fromLocation startLocation: CLLocationCoordinate2D, toLocation endLocation: CLLocationCoordinate2D) -> Double {
        
        let earthRadius = 6378.137 // Earth radius in km
        
        // Calculate delta lat/long
        let dLat = (endLocation.latitude - startLocation.latitude) * Double.pi / 180
        let dLong = (endLocation.longitude - startLocation.longitude) * Double.pi / 180
        
        // Some crazy math
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(startLocation.latitude * Double.pi / 180) * cos(endLocation.latitude * Double.pi / 180) * sin(dLong / 2) * sin(dLong / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let d = earthRadius * c
        
        return d * 1000
    }
}

// MARK: - GMSMapViewDelegate

extension ExploreViewController: GMSMapViewDelegate {
    
//    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
//        infoMarker.snippet = placeID
//        infoMarker.position = location
//        infoMarker.title = name
//        infoMarker.opacity = 0
//        infoMarker.infoWindowAnchor.y = 1
//        infoMarker.map = mapView
//        mapView.selectedMarker = infoMarker
//    }
//    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        let visibleRegion = mapView.projection.visibleRegion()
        let currentLocation = position.target
        let radius = calculateDistance(fromLocation: currentLocation, toLocation: visibleRegion.nearLeft)
        
        APIClient.updateLocations(withinRadius: radius, location: currentLocation) { places in
            guard let places = places else {
                print("Error updating locations")
                return
            }
            
            // Place markers on main queue
            DispatchQueue.main.async {
                for place in places {
                    let infoMarker = GMSMarker(position: place.location)
                    infoMarker.title = place.name
                    infoMarker.opacity = 1.0
                    infoMarker.map = mapView
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension ExploreViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
//        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:17)
//        mapView.animate(to: camera)
        let cameraUpdate = GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!))
        mapView.animate(with: cameraUpdate)
        
        self.locationManager.stopUpdatingLocation()
    }
    
}
