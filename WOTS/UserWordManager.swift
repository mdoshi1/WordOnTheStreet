//
//  UserWordManager.swift
//  WOTS
//
//  Created by Max Freundlich on 5/19/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSDynamoDB

class UserWordManager {
    private var dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    static var sharedSession = UserWordManager()
    var userInfo: UserVocab?
    
    init() {
        let session = SessionManager.sharedInstance
        session.getUserData { (info) in
            if(info == nil){
                session.saveUserInfo()
            }
            self.pullUserWordIds { (uv) in
                self.userInfo = uv
            }
        }
    }

    func testing_saveWordMap(){
        //Create buckets with words
        let TI = Int(Date().timeIntervalSince1970)
        let FL1 = ["wordId":"word-id-1","bucket":1,"date":TI] as [String : Any]
        let FL2 = ["wordId":"word-id-2","bucket":1,"date":TI] as [String : Any]
        let FL3 = ["wordId":"word-id-3","bucket":1,"date":TI] as [String : Any]

        let Reg1 = ["wordId":"word-id-4","bucket":2,"date":TI] as [String : Any]
        let Reg2 = ["wordId":"word-id-5","bucket":3,"date":TI] as [String : Any]
        let Reg3 = ["wordId":"word-id-6","bucket":4,"date":TI] as [String : Any]
        let Reg4 = ["wordId":"word-id-7","bucket":3,"date":TI] as [String : Any]

        //create bucket map
        //Create test object
        let testObj = UserVocab()
        testObj?._userId = AWSIdentityManager.default().identityId!
        testObj?._allWords = [FL1 as NSObject,FL2 as NSObject,FL3 as NSObject, Reg1 as NSObject, Reg2 as NSObject, Reg3 as NSObject, Reg4 as NSObject]
        testObj?._flashcardWords = [FL1 as NSObject,FL2 as NSObject,FL3 as NSObject]
        //Save
        dynamoDBObjectMapper.save(testObj!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Map saved.")
        })
    }
    
    func saveUserVocab(data: UserVocab){
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.save(data, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("updated user vocab")
        })
    }
    
    func pullUserWordIds(completion: @escaping (_ data: UserVocab) -> Void){
        //Query using GSI index table
        //What is the top score ever recorded for the game Meteor Blasters?
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId = :userId"
        
        queryExpression.expressionAttributeValues = [
            ":userId" : AWSIdentityManager.default().identityId! ]
        dynamoDBObjectMapper .query(UserVocab.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    for r in result.items as! [UserVocab]{
                       completion(r)
                    }
                }
            }
            return nil
        })
    }
    
    func getWordId(_ englishWord: String, spanishWord: String, completion: @escaping (_ data: WordPairs) -> Void){
        
        //Query using GSI index table
        //What is the top score ever recorded for the game Meteor Blasters?
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "englishWord = :englishWord AND spanishWord = :spanishWord"
        print("----begin query-----")
        print(englishWord)
        print(spanishWord)
        queryExpression.expressionAttributeValues = [
            ":englishWord" : englishWord, ":spanishWord":spanishWord]
        queryExpression.indexName = "spanishLookup"
        dynamoDBObjectMapper .query(WordPairs.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    for r in result.items as! [WordPairs]{
                        completion(r)
                    }
                }
            }
            return nil
        })
    }
    
    func getFlashcardWords(_ data: UserVocab, completion: @escaping (_ data: [Dictionary<String, Any>]) -> Void){
        
        
        var dataSource: [Dictionary<String, Any>] = []
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        var count = 0;
        for k in data._flashcardWords! as! [Dictionary<String, Any>] {
            let queryExpression = AWSDynamoDBQueryExpression()
            queryExpression.keyConditionExpression = "wordId = :id"
            queryExpression.expressionAttributeValues = [":id" : k["wordId"] as! String]
            dynamoDBObjectMapper .query(WordPairs.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
                
                if let paginatedOutput = task.result {
                    for item in paginatedOutput.items as! [WordPairs] {
                        let m = data._flashcardWords?[count] as! Dictionary<String, Any>
                        let dict = ["english": item._englishWord, "spanish":item._spanishWord, "bucket":m["bucket"], "index": count, "movedUp": false]
                        dataSource.append(dict as [String : Any])
                    }
                }
                count += 1
                if(count == data._flashcardWords?.count){
                    completion(dataSource)
                }
                return nil
            })
        }
        
    }
    
    func getAllWords(_ data: UserVocab, completion: @escaping (_ data: [Dictionary<String, Any>]) -> Void){
        var dataSource: [Dictionary<String, Any>] = []
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        var count = 0;
        for k in data._allWords as! [Dictionary<String, Any>] {
            let queryExpression = AWSDynamoDBQueryExpression()
            queryExpression.keyConditionExpression = "wordId = :id"
            queryExpression.expressionAttributeValues = [":id" : k["wordId"] as! String]
            dynamoDBObjectMapper .query(WordPairs.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
                
                if let paginatedOutput = task.result {
                    for item in paginatedOutput.items as! [WordPairs] {
                        let m = data._allWords?[count] as! Dictionary<String, Any>
                        let dict = ["english": item._englishWord, "spanish":item._spanishWord, "bucket":m["bucket"]]
                        dataSource.append(dict as [String : Any])
                    }
                }
                count += 1
                if(count == data._allWords?.count){
                    completion(dataSource)
                }
                return nil
            })
        }
    }
    
    func getEntireUserVocabTable(){
        let scanExpression = AWSDynamoDBScanExpression()
        dynamoDBObjectMapper.scan(UserVocab.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for r in paginatedOutput.items as! [UserVocab] {
                    // Do something with book.
                    print(r)
                }
            }
            
            return ()
            
        })
    }
    
}
