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
    static var shared = UserWordManager()
    var _userInfo: UserVocab?
    var userInfo: UserVocab? {
        get {
            return _userInfo
        }
        set {
            if (newValue == nil) {
                guard let userVocab = UserVocab(),
                let userId = AWSIdentityManager.default().identityId else {
                    print("Unable to set user vocab because no user is logged in")
                    _userInfo = nil
                    return
                }
                userVocab._userId = userId
                userVocab._allWords = []
                userVocab._flashcardWords = []
                _userInfo = userVocab
            } else {
                _userInfo = newValue
            }
        }
    }
    
//    init() {
//        let session = SessionManager.sharedInstance
//        session.getUserData { (info) in
//            if(info == nil){
//                session.saveUserInfo()
//            }
//            self.pullUserWordIds { (uv) in
//                self.userInfo = uv
//            }
//        }
//    }

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
        AWSDynamoDBObjectMapper.default().save(testObj!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Map saved.")
        })
    }
    
    func updateUserData(wordPair: WordPairs, data: UserVocab){
        let TI = Int(Date().timeIntervalSince1970)
        let wordMap = ["wordId": wordPair._wordId,"bucket":1,"date":TI] as [String : Any]
        data._flashcardWords?.append(wordMap as NSObject)
        data._allWords?.append(wordMap as NSObject)
        AWSDynamoDBObjectMapper.default().save(data)
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
    
    func pullUserWordIds(completion: @escaping (_ data: UserVocab?) -> Void) {
        
        //Query using GSI index table
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId = :userId"
        
        guard let userId = AWSIdentityManager.default().identityId else {
            print("Unable to pull user word ids because no user is logged in")
            completion(nil)
            return
        }
        
        queryExpression.expressionAttributeValues = [
            ":userId" : userId
        ]
        AWSDynamoDBObjectMapper.default().query(UserVocab.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread()) { (task:AWSTask!) -> AnyObject! in
            guard task.error == nil,
                let result = task.result else {
                    print("Amazon DynamoDB query error: \(task.error!.localizedDescription)")
                    return nil
            }
            
            for item in result.items as! [UserVocab]{
                completion(item)
                return nil
            }
            completion(nil)
            return nil
        }
    }
    
    func getWordId(_ englishWord: String, spanishWord: String, completion: @escaping (_ data: WordPairs) -> Void){
        
        //Query using GSI index table
        //What is the top score ever recorded for the game Meteor Blasters?
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "spanishLookup"

        queryExpression.keyConditionExpression = "englishWord = :englishWord"
        print("----begin query-----")
        queryExpression.expressionAttributeValues = [":englishWord" : englishWord]
        AWSDynamoDBObjectMapper.default().query(WordPairs.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    if(result.items.count > 0){
                        for r in result.items as! [WordPairs]{
                            completion(r)
                        }
                    } else {
                        print("nothing there!!! create wordpair, add to users stuff")
                        let wp = WordPairs()
                        wp?._wordId = UUID().uuidString
                        wp?._englishWord = englishWord
                        wp?._spanishWord = spanishWord
                        AWSDynamoDBObjectMapper.default().save(wp!)
                        completion(wp!)
                    }
                }
            }
            return nil
        })
    }
    
    func saveWordAsPair(englishWord:String, spanishWord:String){
        let wp = WordPairs()
        wp?._wordId = UUID().uuidString
        wp?._englishWord = englishWord
        wp?._spanishWord = spanishWord
        AWSDynamoDBObjectMapper.default().save(wp!)
    }
    
    func getFlashcardWords(_ data: UserVocab, completion: @escaping (_ data: [[String: Any]]) -> Void) {
        var dataSource: [[String: Any]] = []
        var count = 0
        guard let flashcardWords = data._flashcardWords as? [[String: Any]] else {
            print("unable to retrieve flashcard words from user vocab data")
            return
        }
        
        for k in flashcardWords {
            let queryExpression = AWSDynamoDBQueryExpression()
            queryExpression.keyConditionExpression = "wordId = :id"
            queryExpression.expressionAttributeValues = [":id" : k["wordId"] as! String]
            AWSDynamoDBObjectMapper.default().query(WordPairs.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread()) { (task:AWSTask!) -> AnyObject! in
                if let paginatedOutput = task.result {
                    for item in paginatedOutput.items as! [WordPairs] {
                        let m = flashcardWords[count]
                        let dict = ["english": item._englishWord, "spanish": item._spanishWord, "bucket": m["bucket"], "index": count, "movedUp": false]
                        dataSource.append(dict as [String : Any])
                    }
                }
                count += 1
                if(count == flashcardWords.count){
                    completion(dataSource)
                }
                return nil
            }
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
        AWSDynamoDBObjectMapper.default().scan(UserVocab.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
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
