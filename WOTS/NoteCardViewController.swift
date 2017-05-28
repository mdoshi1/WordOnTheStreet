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
import AWSMobileHubHelper
import AWSCognitoUserPoolsSignIn
import Flurry_iOS_SDK

class NoteCardViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var goExploreLabel: UILabel!
    @IBOutlet weak var signOutButton:UIButton!
    @IBOutlet weak var takeQuizButton: UIButton!
    
    // MARK: - Properties
    
    private lazy var bottomSheetVC: ScrollableBottomSheetViewController = {
        let bottomSheetVC = ScrollableBottomSheetViewController()
        return bottomSheetVC
    }()

    fileprivate var dataSource: [[String: Any]] = []
    fileprivate var sourceWords: [[String: Any]] = []
    
    var userVoc = UserVocab()
    
    let buttonCornerRadius: CGFloat = 6.0
    
    // MARK: - NoteCardViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if a user is logged in
        presentSignInViewController()
        
        setupView()
        
        // Instrumentation: time spent in Review
        Flurry.logEvent("Tab_Review", timed: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            initData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let count = self.dataSource.count
        dataSource.removeAll()
        kolodaView.removeCardInIndexRange(0..<count, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Instrumentation: time spent in Review
        Flurry.endTimedEvent("Tab_Review", withParameters: nil)
        UserWordManager.shared.saveUserVocab(data: userVoc!)
    }
    
    // MARK: - Helper Methods
    
    private func setupView() {
        
        // General View
        view.backgroundColor = .charcoal
        navigationItem.title = Constants.Storyboard.AppName
        
        // Kolada View
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        // Buttons
        takeQuizButton.layer.cornerRadius = buttonCornerRadius
        signOutButton.layer.cornerRadius = buttonCornerRadius
        signOutButton.layer.borderColor = UIColor.white.cgColor
        
        // Bottom Sheet
        addChildViewController(bottomSheetVC)
        view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParentViewController: self)
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame  = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }
    
    private func presentSignInViewController() {
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            let signInStoryboard = UIStoryboard(name: Constants.Storyboard.SignIn, bundle: nil)
            let signInVC: SignInViewController = signInStoryboard.instantiateViewController(withIdentifier: Constants.Storyboard.SignIn) as! SignInViewController
            signInVC.canCancel = false
            signInVC.didCompleteSignIn = onSignIn
            let navController = UINavigationController(rootViewController: signInVC)
            present(navController, animated: true, completion: nil)
        } else {
            SessionManager.sharedInstance.getUserData { (info) in
                if (info == nil){
                    SessionManager.sharedInstance.initUserInfo()
                }
            }
        }
    }
    
    private func initData() {
        UserWordManager.shared.pullUserWordIds { (userVocab) in
            UserWordManager.shared.userInfo = userVocab
            self.userVoc = UserWordManager.shared.userInfo
            UserWordManager.shared.getFlashcardWords(self.userVoc!) { (source) in
                self.dataSource = source;
                self.sourceWords = source;
                self.kolodaView.insertCardAtIndexRange(0..<self.dataSource.count, animated: true)
                
                // Hide take quiz button if no words
                DispatchQueue.main.async {
                    if (self.dataSource.count) == 0 {
                        self.takeQuizButton.isHidden = true
                        self.goExploreLabel.text = "Looks like you've learned all of your words. You should go explore for more!"
                    } else {
                        self.takeQuizButton.isHidden = false
                        self.goExploreLabel.text = "Tap the card to see the translated word, swipe right if you know the word, swipe left if you don't know the word."
                    }
                }
            }
            UserWordManager.shared.getAllWords(self.userVoc!) { (source) in
                DispatchQueue.main.async {
                    self.bottomSheetVC.setBottomSheetData(source)
                }
            }
        }
    }
    
    func onSignIn(_ success: Bool) {
        if (success) {
            let session = SessionManager.sharedInstance
            session.getUserData { (info) in
                if(info == nil){
                    session.initUserInfo()
                }
            }
        } else {
            // handle cancel operation from user
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func signOut(_ sender: Any) {
        
        // Instrumentation: finish user session
        Flurry.endTimedEvent("User_Session", withParameters: nil)
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            AWSSignInManager.sharedInstance().logout { (result, authState, error) in
                let count = self.dataSource.count
                let position = self.kolodaView.currentCardIndex
                self.dataSource.removeAll()
                self.kolodaView.removeCardInIndexRange(position..<position+count, animated: false)
                self.presentSignInViewController()
            }
        } else {
            assert(false)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TakeQuizSegue" {
            
            // Instrumentation: log tab clicked
            Flurry.logEvent("Review_Quiz")
            
            if let navVC = segue.destination as? UINavigationController {
                let destinationVC = navVC.topViewController as! StandardQuizViewController
                destinationVC.dataSource = self.dataSource
                destinationVC.navigationItem.title = "Quiz"
            }
        }
    }
}

// MARK: - KolodaView Methods

extension NoteCardViewController: KolodaViewDelegate, KolodaViewDataSource {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        let position = kolodaView.currentCardIndex
        for dict in sourceWords{
            dataSource.append(dict);
        }
        kolodaView.insertCardAtIndexRange(position..<position + sourceWords.count, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        guard let noteCard = koloda.viewForCard(at: index) as? NoteCardView else {
            print("Unable to retrieve notecard from KolodaView at index \(index)")
            return
        }
        noteCard.translationView.isHidden = !noteCard.translationView.isHidden
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        let card = dataSource[index]
        let index = card["index"]! as! Int
        var wordMap = userVoc?._flashcardWords?[index] as! [String: Any]
        let date = Date(timeIntervalSince1970: wordMap["date"] as! TimeInterval)
        var bucketNum = wordMap["bucket"] as! Int
        
        // If user didn't know word, move down a bucket
        if( direction == .left){
            
            // Instrumentation: user swiped left
            Flurry.logEvent("NoteCard_Left")
            
            if bucketNum > 1 {
                
                // Instrumentation: user moved down a bucket
                Flurry.logEvent("NoteCard_MovedDownBucket")
                bucketNum -= 1
            }
            SessionManager.sharedInstance.saveUserWordHistoryMap(wordsLearned: -1, word: card["english"] as! String)
        } else if( direction == .right) {
            
            // Instrumentation: user swiped right
            Flurry.logEvent("NoteCard_Right")
            
            //If they got it right and already got it right today dont do anything
            if(SessionManager.sharedInstance.userInfo != nil){
                if(SessionManager.sharedInstance.userInfo?._wordHistory != nil){
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM:dd:YYYY"
                    let dateStr = dateFormatter.string(from: date as Date)
                    let map = SessionManager.sharedInstance.userInfo?._wordHistory?[dateStr] as! [String: Any]
                    let strSet = map["wordSet"] as! Set<String>
                    if(strSet.contains(card["english"] as! String)){
                        return
                    }
                }
            }
            
            //If they aren't in the final bucket move them up
            if(bucketNum < 5){
                
                // Instrumentation: user moved up a bucket
                Flurry.logEvent("NoteCard_MovedUpBucket")
                bucketNum += 1
            }
            SessionManager.sharedInstance.saveUserWordHistoryMap(wordsLearned: 1, word: card["english"] as! String)
        }
        wordMap["bucket"] = bucketNum
        wordMap["date"] = Date().timeIntervalSince1970
        userVoc?._flashcardWords?[index] = wordMap as NSObject
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return dataSource.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let nc = NoteCardView(frame: CGRect(x: 0, y: 0, width: koloda.frame.width, height: koloda.frame.height))
        nc.wordView.text = dataSource[index]["spanish"] as? String
        nc.wordView.sizeToFit()
        nc.translationView.text = dataSource[index]["english"] as? String
        nc.translationView.sizeToFit()
        return nc
    }
}
