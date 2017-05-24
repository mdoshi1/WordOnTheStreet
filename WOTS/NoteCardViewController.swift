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


private var numberOfCards: Int = 5
var sourceWords: [Dictionary<String, Any>] = []


class NoteCardViewController: UIViewController {
    
    @IBOutlet var upGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var goExploreLabel: UILabel!
    var dataSource: [Dictionary<String, Any>] = []
    
    fileprivate var isPresentingForFirstTime = true
    //let userWordManger = UserWordManager.sharedSession
    
    // MARK: Lifecycle
    var bottomSheetVC: ScrollableBottomSheetViewController? = nil
    var userVoc = UserVocab()
    var testedFlashcards = false
    
    @IBOutlet weak var takeQuizButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"chalk-background")!)
        self.view.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        // Check if a user is logged in
        self.presentSignInViewController()
        if AWSSignInManager.sharedInstance().isLoggedIn {
            bottomSheetVC = ScrollableBottomSheetViewController()
        }
        kolodaView.dataSource = self
        kolodaView.delegate = self

        takeQuizButton.layer.cornerRadius = 6;
        // Hide take quiz button if no words
        if (dataSource.count) == 0 {
            takeQuizButton.isHidden = true
            goExploreLabel.isHidden = false
        } else {
            takeQuizButton.isHidden = false
            goExploreLabel.isHidden = true
        }
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        self.navigationItem.title = "Word on the Street"
        
        // Instrumentation: time spent in Review
        Flurry.logEvent("Tab_Review", timed: true)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Instrumentation: time spent in Review
        Flurry.endTimedEvent("Tab_Review", withParameters: nil)
        UserWordManager.shared.saveUserVocab(data: userVoc!)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        var card = self.dataSource[index]
        let i = card["index"]! as! Int
        var wordMap = userVoc?._flashcardWords?[i] as! Dictionary<String, Any>
        let d = Date(timeIntervalSince1970: wordMap["date"] as! TimeInterval)
        var bucketNum = wordMap["bucket"] as! Int
        //If they didnt get pop to bucket 1
        if( direction == .left){
            bucketNum = 1
            SessionManager.sharedInstance.saveUserWordHistoryMap(wordsLearned: -1, word: card["english"] as! String)
        } else if( direction == .right){
            //If they got it right and already got it right today dont do anything
            if(SessionManager.sharedInstance.userInfo != nil){
                if(SessionManager.sharedInstance.userInfo?._wordHistory != nil){
                    let d = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM:dd:YYYY"
                    let dateStr = dateFormatter.string(from: d as Date)
                    let map = SessionManager.sharedInstance.userInfo?._wordHistory?[dateStr] as! Dictionary<String, Any>
                    let strSet = map["wordSet"] as! Set<String>
                    if(strSet.contains(card["english"] as! String)){
                        return
                    }
                }
            }
            //If they aren't in the final bucket move them up
            if(bucketNum < 5){
                bucketNum += 1
            }
            SessionManager.sharedInstance.saveUserWordHistoryMap(wordsLearned: 1, word: card["english"] as! String)
        }
        wordMap["bucket"] = bucketNum
        wordMap["date"] = Date().timeIntervalSince1970
        userVoc?._flashcardWords?[i] = wordMap as NSObject
        testedFlashcards = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let count = self.dataSource.count
        self.dataSource.removeAll()
        self.kolodaView.removeCardInIndexRange(0..<0+count, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(!self.isPresentingForFirstTime){
            initData()
        }
    }
    
    
    
    @IBAction func signOut(_ sender: Any) {
        // Instrumentation: finish user session
        Flurry.endTimedEvent("User_Session", withParameters: nil)
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
                self.navigationController!.popToRootViewController(animated: false)
                let count = self.dataSource.count
                let position = self.kolodaView.currentCardIndex
                self.dataSource.removeAll()
                self.kolodaView.removeCardInIndexRange(position..<position+count, animated: false)
                self.presentSignInViewController()
            })
            // print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            assert(false)
        }

    }
    func onSignIn (_ success: Bool) {
        
        if (success) {
            let session = SessionManager.sharedInstance
            session.getUserData { (info) in
                if(info == nil){
                    session.saveUserInfo()
                }
                if(self.isPresentingForFirstTime){
                    self.initData()
                }
            }
            
        } else {
            // handle cancel operation from user
        }
    }

    func initData(){
      //  userWordManger.testing_saveWordMap()
        UserWordManager.shared.pullUserWordIds { (userVocab) in
            self.userVoc = userVocab
            UserWordManager.shared.getFlashcardWords(userVocab, completion: { (source) in
                self.dataSource = source;
                sourceWords = source;
                self.kolodaView.insertCardAtIndexRange(0..<0 + self.dataSource.count, animated: true)
            })
            UserWordManager.shared.getAllWords(userVocab, completion: { (source) in
                self.bottomSheetVC?.setBottomSheetData(source: source)
            })
        }
    }

    
    func presentSignInViewController() {
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            let loginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
            let loginController: SignInViewController = loginStoryboard.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
            loginController.canCancel = false
            loginController.didCompleteSignIn = onSignIn
            let navController = UINavigationController(rootViewController: loginController)
            navigationController?.present(navController, animated: true, completion: nil)
        } else {
            let session = SessionManager.sharedInstance
            session.getUserData { (info) in
                if(info == nil){
                    session.saveUserInfo()
                }
                self.initData()
            }
        }
    }
    
    func transition(){
        dismiss(animated: true, completion: nil)
    }

    // Show the WordListView at the bottom like the Google Maps interface
    func addBottomSheetView() {
        // 1- Init bottomSheetVC
//        let bottomSheetVC = WordListTableViewController()
        // 2- Add bottomSheetVC as a child view
        self.addChildViewController(bottomSheetVC!)
        self.view.addSubview((bottomSheetVC?.view)!)
        bottomSheetVC?.didMove(toParentViewController: self)
        
        // 3- Adjust bottomSheet frame and initial position.
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC?.view.frame  = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.isPresentingForFirstTime) {
            if AWSSignInManager.sharedInstance().isLoggedIn {
                addBottomSheetView()
                self.isPresentingForFirstTime = false
            }
        }
    }
    
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
        nc.wordView.text = dataSource[Int(index)]["spanish"] as! String
        nc.wordView.sizeToFit()
        nc.translationView.text = dataSource[Int(index)]["english"] as! String
        nc.translationView.sizeToFit()
        return nc
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        //return Bundle.main.loadNibNamed("NoteCardOverlayView", owner: self, options: nil)?[0] as? OverlayView
        return nil
    }
    
    func koloda(koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
        switch direction {
        case .left :
            
            // Instrumentation: user swiped left
            Flurry.logEvent("NoteCard_Left")
            break
        case .right :
            
            // Instrumentation: user swiped right
            Flurry.logEvent("NoteCard_Right")

            break
        default:
            break
        }
    }
}


