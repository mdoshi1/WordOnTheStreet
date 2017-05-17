//
//  ExploreViewController.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 4/29/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import GoogleMaps
import Flurry_iOS_SDK

class ExploreViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate lazy var mapView: GMSMapView = {
        
        // Default location to CS 377U classroom
        let camera = GMSCameraPosition.camera(withLatitude: 37.43, longitude: -122.17, zoom: 17.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        return mapView
    }()
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate var clusterManager: GMUClusterManager!
    fileprivate let placeDetailSegue = "toPlaceDetails"
    fileprivate var placesDict = [String: Place]()

    // MARK: - ExploreViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup mapview
        self.view.addSubview(mapView.usingAutolayout())
        setupConstraints()
        
        // Setup cluster manager
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: GMUDefaultClusterIconGenerator())
        clusterManager = GMUClusterManager(map: mapView, algorithm: GMUGridBasedClusterAlgorithm(), renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
        
        // Go to current location
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        self.navigationItem.title = "Word on the Street"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Instrumentation: time spent in Explore
        Flurry.logEvent("Tab_Explore", timed: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Instrumentation: time spent in Explore
        Flurry.endTimedEvent("Tab_Explore", withParameters: nil)
    }
    
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Map View
        let bottomMargin = self.tabBarController?.tabBar.frame.height ?? 49.0
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let place = sender as? Place,
            let destinationVC = segue.destination as? PlaceDetailViewController {
            destinationVC.place = place
        }
    }
}

// MARK: - GMSMapViewDelegate

extension ExploreViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        print("Camera became idle at")
        
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
                    if self.placesDict[place.placeId] == nil {
                        self.placesDict[place.placeId] = place
                        self.clusterManager.add(place)
                    }
//                    let infoMarker = GMSMarker(position: place.location)
//                    infoMarker.title = place.name
//                    infoMarker.opacity = 1.0
//                    infoMarker.infoWindowAnchor = CGPoint(x: 0, y: -0.2)
//                    infoMarker.userData = place
//                    infoMarker.map = mapView
                    
//                    if mapViewBounds.contains(place.position) {
//                        self.clusterManager.add(place)
//                    }
                }
                self.clusterManager.cluster()
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let markerInfoView = MarkerInfoView(frame: CGRect(x: 0, y: 0, width: 200.0, height: 60.0), forMarker: marker)

        // Instrumentation: What kind of pin did the user click on?
        if let place = marker.userData as? Place {
            let flurryParams = ["name": place.name,
                                "placeId": place.placeId,
                                "numWords": place.numWords,
                                "numPeople": place.numPeople,
                                "location": place.position
                ] as [String: Any]
            Flurry.logEvent("Explore_Pin", withParameters: flurryParams)
        } else {
            Flurry.logEvent("Explore_Pin", withParameters: ["name": "Marker did not have Place data"])
        }
        
        return markerInfoView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.selectedMarker = marker
        if let place = marker.userData as? Place {
            print("Place marker was tapped")
            APIClient.getWords(forPlace: place) { vocab in
                guard let vocab = vocab else {
                    print("Error retrieving vocab for selected marker")
                    return
                }
                place.updateVocab(vocab)
            }
        } else {
            print("Map cluster was tapped")
        }
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        // Instrumentation: User clicked onto info window
        let place = marker.userData as! Place
        let flurryParams = ["name": place.name,
                            "placeId": place.placeId,
                            "numWords": place.numWords,
                            "numPeople": place.numPeople,
                            "location": place.position
            ] as [String: Any]
        Flurry.logEvent("Explore_Pin_Info_Window", withParameters: flurryParams)
        
        performSegue(withIdentifier: placeDetailSegue, sender: marker.userData)
    }
}

// MARK: - GMUClusterManagerDelegate

extension ExploreViewController: GMUClusterManagerDelegate {
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        print("Did tap cluster")
        let cameraUpdate = GMSCameraUpdate.setTarget(cluster.position, zoom: mapView.camera.zoom + 1.0)
        mapView.animate(with: cameraUpdate)
        return true
    }
}

// MARK: - CLLocationManagerDelegate

extension ExploreViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let cameraUpdate = GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!))
        mapView.animate(with: cameraUpdate)
        
        self.locationManager.stopUpdatingLocation()
    }
}

// TODO: Move to an extension file
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
