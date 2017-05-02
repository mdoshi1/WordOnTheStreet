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
        let camera = GMSCameraPosition.camera(withLatitude: 37.43, longitude: 122.17, zoom: 6.0)
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

        self.view.addSubview(mapView.usingAutolayout())
        setupConstraints()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Map View
        let bottomMargin = self.tabBarController?.tabBar.frame.height ?? 49.0
        print(bottomMargin)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -bottomMargin)
            ])
    }
}

// MARK: - GMSMapViewDelegate

extension ExploreViewController: GMSMapViewDelegate {
    
}

// MARK: - CLLocationManagerDelegate

extension ExploreViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:14)
        mapView.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }
    
}
