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
        user?._userId = AWSIdentityManager.default().identityId!
        user?._achievements = nil
        user?._wordGoal = 3
        user?._history = nil
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

class UserFilesViewController {
    
    private func uploadWithData(data: NSData, forKey key: String) {
        let manager = AWSUserFileManager.defaultUserFileManager()
        let localContent = manager.localContent(with: data as Data, key: key)
        localContent.uploadWithPin(
            onCompletion: false,
            progressBlock: {[weak self](content: AWSLocalContent, progress: Progress) -> Void in
                guard let strongSelf = self else { return }
                /* Show progress in UI. */
            },
            completionHandler: {[weak self](content: AWSLocalContent?, error: Error?) -> Void in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("Failed to upload an object. \(error)")
                } else {
                    print("Object upload complete. \(error)")
                }
        })
    }
    
    private func downloadContent(content: AWSContent, pinOnCompletion: Bool) {

        content.download(
            with: .ifNewerExists,
            pinOnCompletion: pinOnCompletion,
            progressBlock: {[weak self](content: AWSContent, progress: Progress) -> Void in
                guard let strongSelf = self else { return }
                /* Show progress in UI. */
            },
            completionHandler: {[weak self](content: AWSContent?, data: Data?, error: Error?) -> Void in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("Failed to download a content from a server. \(error)")
                    return
                }
                print("Object download complete.")
        })
    }
}
