//
//  Place.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 5/15/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import Foundation

class Place: NSObject, GMUClusterItem {
    
    let name: String
    let placeId: String
    let position: CLLocationCoordinate2D
    // let types: [String]
    // let photos: [String]
    var numWords: Int
    var numPeople: Int
    var vocab: Vocab?
    
    init?(dictionary: JSONDictionary) {
        guard let name = dictionary["name"] as? String,
            let placeId = dictionary["place_id"] as? String,
            let geometry = dictionary["geometry"] as? JSONDictionary,
            let position = geometry["location"] as? JSONDictionary,
            let lat = position["lat"] as? Double,
            let long = position["lng"] as? Double else {
                print("Error in one or more fields of Place JSON")
                return nil
        }
        self.name = name
        self.placeId = placeId
        self.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.numWords = Int(arc4random_uniform(20))
        self.numPeople = Int(arc4random_uniform(20))
    }
    
    func updateVocab(_ vocab: Vocab) {
        self.vocab = vocab
        self.numWords = vocab.dict.count
    }
    
    override var description: String {
        return "Name: \(name), Id: \(placeId)"
    }
}
