//
//  Achievements.swift
//  WOTS
//
//  Created by Max Freundlich on 5/13/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import Foundation
import AWSMobileHubHelper
import AWSDynamoDB

class Achievements: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var achievementId: String?
    var detail: String?
    var image: String?
    
    class func dynamoDBTableName() -> String {
        return "wordonthestreet-mobilehub-915338963-Achievements"
    }
    
    class func hashKeyAttribute() -> String {
        return "achievementId"
    }
    
}
