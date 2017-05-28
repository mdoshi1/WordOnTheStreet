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
    static let sharedInstance = SessionManager()
    var userInfo: UserInformation?
    
    func initUserInfo(){
        guard let user = UserInformation(),
            let userId = AWSIdentityManager.default().identityId else {
            print("Unable to initialize new user info because no user is logged in")
            return
        }
        user._userId = userId
        user._achievements = nil
        user._wordGoal = 3
        user._history = nil
        userInfo = user
        AWSDynamoDBObjectMapper.default().save(user, completionHandler: {(error: Error?) -> Void in
            guard error == nil else {
                print("Amazon DynamoDB save error: \(error!.localizedDescription)")
                return
            }
            print("New user saved")
        })
    }
    
    func setUserWordGoal(goal: Int){
        AWSDynamoDBObjectMapper.default().save(self.userInfo!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("User goal updated.")
        })
        
    }
    
    func saveUserWordHistory(wordsLearned: Int){
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
        AWSDynamoDBObjectMapper.default().save(self.userInfo!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("User word history saved")
        })
    }
    
    func saveUserWordHistoryMap(wordsLearned: Int, word: String){
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM:dd:YYYY"
        let dateStr = dateFormatter.string(from: date as Date)
        var numWords = 0
        var strSet: Set<String> = []
        if self.userInfo?._wordHistory?[dateStr] != nil {
            let map = self.userInfo?._wordHistory?[dateStr] as! [String: Any]
            numWords = map["wordCount"] as! Int
            strSet = map["wordSet"] as! Set<String>
        }
        numWords += wordsLearned
        if(self.userInfo?._wordHistory == nil){
            var newSet: Set<String> = []
            if(wordsLearned < 0){
                numWords = 0
            } else {
                newSet.insert(word)
            }
            let map = ["wordCount": numWords, "wordSet": newSet] as [String : Any]
            self.userInfo?._wordHistory = [dateStr:map as NSObject]
        } else {
            if(wordsLearned < 0){
                strSet.remove(word)
                if(numWords <= 0){
                    numWords = 0
                    strSet.insert("void-str")
                }
            } else {
                strSet.insert(word)
                strSet.remove("void-str")
            }
            let map = ["wordCount": numWords, "wordSet": strSet] as [String : Any]
            self.userInfo?._wordHistory?.updateValue(map as NSObject, forKey: dateStr)
        }
        AWSDynamoDBObjectMapper.default().save(self.userInfo!) {(error: Error?) -> Void in
            guard error == nil else {
                print("Amazon DynamoDB Save Error: \(error!.localizedDescription)")
                return
            }
            print("User word history saved")
        }
    }
    
    func getUserData(completion: @escaping (_ data: UserInformation?) -> Void){
        
        // Query using GSI index table
        guard let identityId = AWSIdentityManager.default().identityId else {
            print("Unable to get user data because no user is logged in")
            completion(nil)
            return
        }
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId = :userId"
        
        queryExpression.expressionAttributeValues = [
            ":userId" : identityId ]
        AWSDynamoDBObjectMapper.default().query(UserInformation.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread()) { (task: AWSTask!) -> AnyObject! in
            guard task.error == nil,
                let result = task.result else {
                    print("Amazon DynamoDB query error: \(task.error!.localizedDescription)")
                    completion(nil)
                    return nil
            }
            
            for item in result.items as! [UserInformation] {
                self.userInfo = item
                completion(item)
                return nil
            }
            completion(nil)
            return nil
        }
    }
}
