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
        self.dynamoDBObjectMapper.save(self.userInfo!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("User goal updated.")
        })
//        let queryExpression = AWSDynamoDBQueryExpression()
//        queryExpression.keyConditionExpression = "userId = :userId"
//        
//        queryExpression.expressionAttributeValues = [
//            ":userId" : AWSIdentityManager.default().identityId! ]
//        dynamoDBObjectMapper .query(UserInformation.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
//            if let error = task.error as NSError? {
//                print("Error: \(error)")
//            } else {
//                if let result = task.result {//(task.result != nil) {
//                    for r in result.items as! [UserInformation]{
//                        r._wordGoal = goal as NSNumber
//                        self.dynamoDBObjectMapper.save(r, completionHandler: {(error: Error?) -> Void in
//                            if let error = error {
//                                print("Amazon DynamoDB Save Error: \(error)")
//                                return
//                            }
//                            print("User goal updated.")
//                        })
//                        return nil
//                    }
//                }
//            }
//            return nil
//        })
        
    }
    
    func saveUserWordHistory(wordsLearned: Int){
        //05:135:2017
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM:dd:YYYY"
        let dateStr = dateFormatter.string(from: date as Date)
        print(dateStr)
        var numWords = 0
        if self.userInfo?._history?[dateStr] != nil {
            numWords = self.userInfo?._history?[dateStr]! as! Int
        }
        numWords += wordsLearned
        //self.userInfo?._history?[dateStr] = numWords as NSObject
        if(self.userInfo?._history == nil){
            self.userInfo?._history = [dateStr: numWords as NSObject]
        } else {
            self.userInfo?._history?.updateValue(numWords as NSObject, forKey: dateStr)
        }
        self.dynamoDBObjectMapper.save(self.userInfo!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("User word history saved")
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
