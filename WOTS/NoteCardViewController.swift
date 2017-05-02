//
//  NoteCardViewController.swift
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
var sourceWords: [Dictionary<String, String>] = []


class NoteCardViewController: UIViewController {
    
    @IBOutlet var upGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var kolodaView: KolodaView!
    
//    fileprivate var dataSource: [UIImage] = {
//        var array: [UIImage] = []
//        for index in 0..<numberOfCards {
//            array.append(UIImage(named: "Card_like_\(index + 1)")!)
//        }
//        
//        return array
//    }()
    var dataSource: [Dictionary<String, String>] = []
    
    fileprivate var isPresentingForFirstTime = true
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.dataSource = self
        kolodaView.delegate = self
      //  insertData()
        getWordsForUser()
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
    }
    
    
    // MARK: IBActions
    
    @IBAction func upSwiped(_ sender: Any) {
        print ("swiped up")
    }

    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(.left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(.right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
    
    
    // Show the WordListView at the bottom like the Google Maps interface
    func addBottomSheetView() {
        // 1- Init bottomSheetVC
//        let bottomSheetVC = WordListTableViewController()
        let bottomSheetVC = ScrollableBottomSheetViewController()

        
        // 2- Add bottomSheetVC as a child view
        self.addChildViewController(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParentViewController: self)
        
        // 3- Adjust bottomSheet frame and initial position.
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame  = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.isPresentingForFirstTime) {
            addBottomSheetView()
            self.isPresentingForFirstTime = false
        }
    }
    // MARK: AWS functions
    func getWordsForUser(){
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
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
                        let dict = ["word": r.spanishWord, "translation": r.englishWord]
                       // myNewDictArray.append(dict)
                        self.dataSource.append(dict);
                        sourceWords.append(dict)
                        print(r.spanishWord);
                    }
                    let position = self.kolodaView.currentCardIndex
                    self.kolodaView.insertCardAtIndexRange(position..<position + result.items.count, animated: true)
                }
               
            }
            return nil
        })
    }
    //Example insert data function. Used to initialize data set
    func insertData() {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        for dic in dataSource {
            let itemToCreate: Word = Word()
            
            itemToCreate.userId = AWSIdentityManager.default().identityId!
            itemToCreate.englishWord = dic["translation"]!
            itemToCreate.spanishWord = dic["word"]!

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
        return "wordonthestreet-mobilehub-915338963-EnglishVocabSet"
    }
    
    class func hashKeyAttribute() -> String {
        return "userId"
    }
    
    class func rangeKeyAttribute() -> String {
        return "englishWord"
    }
    
}

// MARK: KolodaViewDelegate

extension NoteCardViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        let position = kolodaView.currentCardIndex
//        for i in 1...4 {
//            dataSource.append(UIImage(named: "Card_like_\(i)")!)
//        }
        for dict in sourceWords{
            dataSource.append(dict);
        }
        kolodaView.insertCardAtIndexRange(position..<position + sourceWords.count, animated: true)
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

