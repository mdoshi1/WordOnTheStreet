//
//  UserInformation.swift
//  WOTS
//
//  Created by Max Freundlich on 5/13/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import Foundation
import AWSMobileHubHelper
import AWSDynamoDB

class UserInformation: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var userId: String?
    var achievements: Set<String>?
    var history: Dictionary<String, NSObject>?
    var wordGoal: NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "wordonthestreet-mobilehub-915338963-UserInformation"
    }
    
    class func hashKeyAttribute() -> String {
        return "userId"
    }
    
}
