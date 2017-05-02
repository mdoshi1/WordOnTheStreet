//
//  ViewController.swift
//  Koloda
//
//  Created by Eugene Andreyev on 4/23/15.
//  Copyright (c) 2015 Eugene Andreyev. All rights reserved.
//

import UIKit
import Koloda
import AWSMobileHubHelper
import AWSDynamoDB


private var numberOfCards: Int = 5

class NoteCardViewController: UIViewController {
    
    @IBOutlet weak var kolodaView: KolodaView!
    
//    fileprivate var dataSource: [UIImage] = {
//        var array: [UIImage] = []
//        for index in 0..<numberOfCards {
//            array.append(UIImage(named: "Card_like_\(index + 1)")!)
//        }
//        
//        return array
//    }()
    fileprivate var dataSource: [Dictionary<String, String>] = {
        var myNewDictArray: [Dictionary<String, String>] =  [
            ["word" : "cafe", "translation": "coffee"],
            ["word" : "leche", "translation": "milk"],
            ["word" : "azucar", "translation": "sugar"],
            ["word" : "paja", "translation": "straw"]
        ]
        return myNewDictArray
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        insertData()
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
    }
    
    
    // MARK: IBActions
    
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(.left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(.right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
    
    // MARK: AWS functions
    //Example insert data function. Used to initialize data set
    func insertData() {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        for dic in dataSource {
            let itemToCreate: Word = Word()
            
            itemToCreate.userId = AWSIdentityManager.default().identityId!
            itemToCreate.englishWord = dic["translation"]!
            itemToCreate.spanishWord = dic["word"]!
            print("--------")
            print(itemToCreate.englishWord)
            print(itemToCreate.userId)
            print(itemToCreate.spanishWord)
            print("--------")

            objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
                if let error = error {
                    print("Amazon DynamoDB Save Error: \(error)")
                    return
                    
                }
                print("Item saved.")
            })
        }
    }
}

//class that gets the objects from db
class Word: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var userId:String = ""
    var englishWord:String = ""
    var spanishWord:String = ""
    
    
    class func dynamoDBTableName() -> String {
        return "wordonthestreet-mobilehub-915338963-VocabularySet"
    }
    
    class func hashKeyAttribute() -> String {
        return "englishWord"
    }
    
    class func rangeKeyAttribute() -> String {
        return "userId"
    }
    
}

// MARK: KolodaViewDelegate

extension NoteCardViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        let position = kolodaView.currentCardIndex
//        for i in 1...4 {
//            dataSource.append(UIImage(named: "Card_like_\(i)")!)
//        }
        dataSource.append(["word" : "cafe", "translation": "coffee"])
        dataSource.append(["word" : "leche", "translation": "milk"])
        dataSource.append(["word" : "azucar", "translation": "sugar"])
        dataSource.append(["word" : "paja", "translation": "straw"])
        kolodaView.insertCardAtIndexRange(position..<position + 4, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
//        UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
        let nc = koloda.viewForCard(at: index) as? NoteCardView
        nc?.translationView.isHidden = !(nc?.translationView.isHidden)!;
    }
    
}

// MARK: KolodaViewDataSource

extension NoteCardViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return dataSource.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let nc = NoteCardView(frame: CGRect(x: 0, y: 0, width: koloda.frame.width, height: koloda.frame.height))
        nc.wordView.text = dataSource[Int(index)]["word"]
        nc.translationView.text = dataSource[Int(index)]["translation"]
        return nc
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        //return Bundle.main.loadNibNamed("NoteCardOverlayView", owner: self, options: nil)?[0] as? OverlayView
        return nil
    }
}

