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
var sourceWords: [Dictionary<String, String>] = []


class NoteCardViewController: UIViewController {
    
    @IBOutlet var upGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var kolodaView: KolodaView!
    
    var dataSource: [Dictionary<String, String>] = []
    
    fileprivate var isPresentingForFirstTime = true
    let noteCardConn = NoteCardConnection()
    // MARK: Lifecycle
    
    
    @IBOutlet weak var takeQuizButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"chalk-background")!)
        self.view.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        // Check if a user is logged in

        kolodaView.dataSource = self
        kolodaView.delegate = self
//        noteCardConn.insertData { () in
//            noteCardConn.getWordsForUser { (source) in
//                self.dataSource = source;
//                sourceWords = source;
//                let position = self.kolodaView.currentCardIndex
//                self.kolodaView.insertCardAtIndexRange(position..<position + self.dataSource.count, animated: true)
//            }
//        }
        //noteCardConn.saveTestWordMap()
        noteCardConn.getAllUserWords(forNotecards: true){ (source) in
            self.dataSource = source;
            sourceWords = source;
            let position = self.kolodaView.currentCardIndex
            self.kolodaView.insertCardAtIndexRange(position..<position + self.dataSource.count, animated: true)
        }
        takeQuizButton.layer.cornerRadius = 6;
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        self.navigationItem.title = "Word on the Street"
        
        // Instrumentation: time spent in Review
        Flurry.logEvent("Tab_Review", timed: true)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Instrumentation: time spent in Review
        Flurry.endTimedEvent("Tab_Review", withParameters: nil)
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
    
    @IBAction func signOut(_ sender: Any) {
        // Instrumentation: finish user session
        Flurry.endTimedEvent("User_Session", withParameters: nil)
        
        CredentialManager.credentialsProvider.clearCredentials()
        CredentialManager.credentialsProvider.clearKeychain()
        AWSSignInManager.sharedInstance().logout { (obj, auth, err) in
            if((err) != nil) {
                print(err!)
            } else {
                let pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
                let user = pool.currentUser()
                user?.forgetDevice()
                user?.signOut()
                self.transition()
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
        nc.wordView.text = dataSource[Int(index)]["spanish"]
        nc.translationView.text = dataSource[Int(index)]["english"]
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


