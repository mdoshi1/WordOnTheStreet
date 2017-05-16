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
        
        let resource = Resource<[Place]>(urlRequest: request) { json in
            guard let response = json as? JSONDictionary else {
                print("Failed to cast JSON response as a JSONDictionary")
                return nil
            }
            guard let data = response["results"] as? [JSONDictionary] else {
                print("Failed to cast JSON data as an array of JSONDictionary")
                return nil
            }
            return data.flatMap(Place.init)
        }
        
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
    
    class func getWords(forPlace place: Place, completion: @escaping (Vocab?) -> ()) {
        let lat = place.position.latitude
        let long = place.position.longitude
        let urlString = "https://ra1xa35x56.execute-api.us-west-2.amazonaws.com/testing/prepopulate?latitude=\(lat)&longitude=\(long)"
        guard let url = URL(string: urlString) else {
            print("Error generating URL from string: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let resource = Resource<Vocab>(urlRequest: request) { json in
            print("json \(json)")
            guard let response = json as? JSONDictionary else {
                print("Failed to cast JSON response as a JSONDictionary")
                return nil
            }
            return Vocab(dictionary: response)
        }
        
        load(resource: resource) { vocab in
            guard let vocab = vocab else {
                print("Error in retrieving vocab")
                completion(nil)
                return
            }
            print("Success in retrieving vocab")
            completion(vocab)
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

struct Vocab {
    var dict: [String: String] = [:]
}

extension Vocab {
    init?(dictionary: JSONDictionary) {
        guard let words = dictionary["words"] as? [String],
            let translations = dictionary["translated"] as? [String] else {
                print("Error in one or more fields of Vocab JSON")
                return nil
        }
        for index in 0..<words.count {
            dict[words[index]] = translations[index]
        }
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
