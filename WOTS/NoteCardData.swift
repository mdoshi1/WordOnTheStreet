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
    
//    init() {
//        //Repeatedly attempt to get the id
//        while(AWSIdentityManager.default().identityId == nil){
//            let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
//                                                                    identityPoolId:"us-east-1:fb15d096-3f42-4c86-87c0-2db4339ca572")
//            credentialsProvider.getIdentityId().continueWith { (task) -> Any? in
//                if (task.error != nil) {
//                    print("Error: " + (task.error?.localizedDescription)!)
//                }
//                return nil
//            }
//        }
//    }
    // MARK: AWS functions
    func getWordsForUser(completion: @escaping (_ data: [Dictionary<String, String>]) -> Void){
        var dataSource: [Dictionary<String, String>] = []

        //Query using GSI index table
        //What is the top score ever recorded for the game Meteor Blasters?
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId = :userId"
        
        queryExpression.expressionAttributeValues = [
            ":userId" : AWSIdentityManager.default().identityId! ];
        dynamoDBObjectMapper .query(Word.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    for r in result.items as! [Word]{
                        let dict = ["spanish": r.spanishWord, "english": r.englishWord]
                        dataSource.append(dict)
                    }
                    completion(dataSource);
                }
            }
            return nil
        })
    }
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
        
        let mapElement = ["word-id-1" : 99 as NSNumber,"word-id-3" : 87 as NSNumber] as Dictionary<String, NSObject>
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
    
    func getAllWordIds(){
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
                        print(dict!)
                        self.updateTestWordMap(objToUpdate: r)
                    }
                }
            }
            return nil
        })
    }
    
    //Example insert data function. Used to initialize data set
    func insertData(completion: ()->Void) {
        let dataSource: [Dictionary<String, String>] = [
            ["english": "coffee", "spanish":"cafe"],
            ["english": "milk", "spanish":"leche"],
            ["english": "straw", "spanish":"paja"],
            ["english": "sugar", "spanish":"azucar"]
        ]
        let objectMapper = AWSDynamoDBObjectMapper.default()
        var count = 0;
        for dic in dataSource {
            let itemToCreate: Word = Word()
            
            itemToCreate.userId = AWSIdentityManager.default().identityId!
            itemToCreate.englishWord = dic["english"]!
            itemToCreate.spanishWord = dic["spanish"]!
            
            objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
                if let error = error {
                    print("Amazon DynamoDB Save Error: \(error)")
                    count += 1
                    return
                }
                print("Item saved.")
                count += 1
            })
        }
        while(true){
            if(count == dataSource.count){
                completion()
                break;
            }
        }
    }
}
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
//class that gets the objects from db
class Word: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var userId:String = ""
    var englishWord:String = ""
    var spanishWord:String = ""
    
    
    class func dynamoDBTableName() -> String {
        return "wordonthestreet-mobilehub-915338963-EnglishVocabSet"
    }
    
    class func hashKeyAttribute() -> String {
        return "userId"
    }
    
    class func rangeKeyAttribute() -> String {
        return "englishWord"
    }
    
}
