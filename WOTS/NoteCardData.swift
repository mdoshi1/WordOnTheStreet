//
//  File.swift
//  WOTS
//
//  Created by Max Freundlich on 5/2/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSDynamoDB

class NoteCardConnection {
    private var dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()

    func saveTestWordMap(){
        let mapElement = ["word-id" : 98 as NSNumber] as Dictionary<String, NSObject>
        let testObj = WordIds()
        testObj?.userId = AWSIdentityManager.default().identityId!
        testObj?.wordMap = mapElement
        let objectMapper = AWSDynamoDBObjectMapper.default()

        objectMapper.save(testObj!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Map saved.")
        })
    }
    
    func updateTestWordMap(objToUpdate: WordIds){
        
        let mapElement = ["word-id-4" : 23 as NSNumber,"word-id-5" : 46 as NSNumber] as Dictionary<String, NSObject>
        for obj in mapElement {
            objToUpdate.wordMap?[obj.key] = obj.value
        }
        
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(objToUpdate, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Map updated.")
        })
    }
    
    func getAllUserWords(forNotecards: Bool, completion: @escaping (_ data: [Dictionary<String, String>]) -> Void){
        //Query using GSI index table
        //What is the top score ever recorded for the game Meteor Blasters?
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId = :userId"
        
        queryExpression.expressionAttributeValues = [
            ":userId" : AWSIdentityManager.default().identityId! ]
        dynamoDBObjectMapper .query(WordIds.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    for r in result.items as! [WordIds]{
                        let dict = r.wordMap
                        //self.updateTestWordMap(objToUpdate: r)
                        self.getWordsFromIds(forNotecards: forNotecards, wordMap: dict!, completion: completion)
                    }
                }
            }
            return nil
        })
    }
    
    func getWordsFromIds(forNotecards: Bool, wordMap: Dictionary<String, NSObject>, completion: @escaping (_ data: [Dictionary<String, String>]) -> Void){
        let componentArray = Array(wordMap.keys)
        var dataSource: [Dictionary<String, String>] = []

        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        var count = 0;
        for k in componentArray {
            if(forNotecards == true && wordMap[k] as! Int > 50) {
                count+=1
                continue
            } else if(forNotecards == false){
                print(k)
            }
            let queryExpression = AWSDynamoDBQueryExpression()
            queryExpression.keyConditionExpression = "wordId = :id"
            queryExpression.expressionAttributeValues = [":id" : k]
            dynamoDBObjectMapper .query(WordPairs.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
                
                if let paginatedOutput = task.result {
                    for item in paginatedOutput.items as! [WordPairs] {
                        let dict = ["english": item._englishWord, "spanish":item._spanishWord]
                        dataSource.append(dict as! [String : String])
                    }
                }
                count += 1
                if(count == componentArray.count){
                    completion(dataSource)
                }
                return nil
            })
        }

    }
}
