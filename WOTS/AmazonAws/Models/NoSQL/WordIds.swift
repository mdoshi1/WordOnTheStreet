//
//  WordIds.swift
//  WOTS
//
//  Created by Max Freundlich on 5/12/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import AWSMobileHubHelper
import AWSDynamoDB

class WordIds: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var userId: String = ""
    var wordMap: Dictionary<String, NSObject>?
    
    class func dynamoDBTableName() -> String {
        return "wordonthestreet-mobilehub-915338963-UserVocabulary"
    }
    
    class func hashKeyAttribute() -> String {
        return "userId"
    }
    
}
