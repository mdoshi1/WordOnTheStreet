//
//  UserData.swift
//  WOTS
//
//  Created by Max Freundlich on 5/13/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSDynamoDB

class UserData {
    private var dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    
    func saveUserInfo(){
        let user = UserInformation()
        user?.userId = AWSIdentityManager.default().identityId!
        user?.achievements = nil
        user?.wordGoal = 3
        user?.history = nil
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        objectMapper.save(user!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("User saved.")
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
