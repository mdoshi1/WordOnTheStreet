//
//  APIClient.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 5/2/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import Foundation
import CoreLocation

typealias JSONDictionary = [String: AnyObject]

final class APIClient {
        
    class func updateLocations(withinRadius radius: Double, location: CLLocationCoordinate2D, completion: @escaping(JSONDictionary?) -> Void) {
        let lat = location.latitude
        let long = location.longitude
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=\(radius)&key=\(Constants.APIServices.GMSPlacesKey)"
        guard let url = URL(string: urlString) else {
            print("Error generating URL from string: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error processing HTTP request: \(error?.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("Status code should be 200, but is \(httpStatus.statusCode)")
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            guard let dictionary = json as? JSONDictionary else {
                print("Failed to cast dict")
                completion(nil)
                return
            }
            completion(dictionary)
        }.resume()
    }
}
