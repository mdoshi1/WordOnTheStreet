//
//  SessionManager.swift
//  WOTS
//
//  Created by Max Freundlich on 5/14/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import Foundation
import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class SessionManager {
    static var sharedInstance = SessionManager()
    private var dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()

    var userInfo: UserInformation?
    
    func saveUserInfo(){
        let user = UserInformation()
        user?._userId = AWSIdentityManager.default().identityId!
        user?._achievements = nil
        user?._wordGoal = 3
        user?._history = nil
        let objectMapper = AWSDynamoDBObjectMapper.default()
        self.userInfo = user
        objectMapper.save(user!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("User saved.")
        })
    }
    
    func setUserWordGoal(goal: Int){
        self.userInfo?._wordGoal = goal as NSNumber

        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId = :userId"
        
        queryExpression.expressionAttributeValues = [
            ":userId" : AWSIdentityManager.default().identityId! ]
        dynamoDBObjectMapper .query(UserInformation.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    for r in result.items as! [UserInformation]{
                        r._wordGoal = goal as NSNumber
                        self.dynamoDBObjectMapper.save(r, completionHandler: {(error: Error?) -> Void in
                            if let error = error {
                                print("Amazon DynamoDB Save Error: \(error)")
                                return
                            }
                            print("User goal updated.")
                        })
                        return nil
                    }
                }
            }
            return nil
        })
        
    }
    
    func getUserData(completion: @escaping (_ data: UserInformation?) -> Void){
        //Query using GSI index table
        //What is the top score ever recorded for the game Meteor Blasters?
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId = :userId"
        
        queryExpression.expressionAttributeValues = [
            ":userId" : AWSIdentityManager.default().identityId! ]
        dynamoDBObjectMapper .query(UserInformation.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    for r in result.items as! [UserInformation]{
                        self.userInfo = r
                        completion(r)
                        return nil
                    }
                    completion(nil)
                }
            }
            return nil
        })
    }
}
