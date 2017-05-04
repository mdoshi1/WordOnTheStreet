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
    
    class func updateLocations(withinRadius radius: Double, location: CLLocationCoordinate2D, completion: @escaping ([Place]?) -> ()) {
        let lat = location.latitude
        let long = location.longitude
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=\(radius)&key=\(Constants.APIServices.GMSPlacesKey)"
        guard let url = URL(string: urlString) else {
            print("Error generating URL from string: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let resource = Resource<[Place]>(urlRequest: request, parseJSON: { json in
            guard let response = json as? JSONDictionary else {
                print("Failed to cast JSON response as a JSONDictionary")
                return nil
            }
            guard let data = response["results"] as? [JSONDictionary] else {
                print("Failed to cast JSON data as an array of JSONDictionary")
                return nil
            }
            return data.flatMap(Place.init)
        })
        
        load(resource: resource) { places in
            guard let places = places else {
                print("Error in retrieving places")
                completion(nil)
                return
            }
            print("Success in retrieving places")
            completion(places)
        }
    }
    
    private static func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        URLSession.shared.dataTask(with: resource.urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                print("Error processing HTTP request: \(error)")
                completion(nil)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("Status code should be 200, but is \(httpStatus.statusCode)")
                completion(nil)
            }
            
            completion(resource.parse(data))
            }.resume()
    }
}

struct Place {
    let name: String
    let placeId: String
    let location: CLLocationCoordinate2D
}

extension Place {
    init?(dictionary: JSONDictionary) {
        guard let name = dictionary["name"] as? String,
            let placeId = dictionary["place_id"] as? String,
            let geometry = dictionary["geometry"] as? JSONDictionary,
            let location = geometry["location"] as? JSONDictionary,
            let lat = location["lat"] as? Double,
            let long = location["lng"] as? Double else {
                print("Error in one or more fields of Place JSON")
                return nil
        }
        self.name = name
        self.placeId = placeId
        self.location = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}

struct Resource<A> {
    let urlRequest: URLRequest
    let parse: (Data) -> A?
}

extension Resource {
    init(urlRequest: URLRequest, parseJSON: @escaping (Any) -> A?) {
        self.urlRequest = urlRequest
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}
