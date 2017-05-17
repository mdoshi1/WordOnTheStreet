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
import Instructions

private var numberOfCards: Int = 5
var sourceWords: [Dictionary<String, String>] = []


class NoteCardViewController: UIViewController, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    @IBOutlet var upGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var kolodaView: KolodaView!
    let coachMarksController = CoachMarksController()
    
    var dataSource: [Dictionary<String, String>] = []
    
    fileprivate var isPresentingForFirstTime = true
    let noteCardConn = NoteCardConnection()
    // MARK: Lifecycle
    let bottomSheetVC = ScrollableBottomSheetViewController()

    
    @IBOutlet weak var takeQuizButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"chalk-background")!)
        self.view.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        // Check if a user is logged in
        self.presentSignInViewController()

        kolodaView.dataSource = self
        kolodaView.delegate = self

        takeQuizButton.layer.cornerRadius = 6;
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        self.navigationItem.title = "Word on the Street"
        
        // Instrumentation: time spent in Review
        Flurry.logEvent("Tab_Review", timed: true)
        
        // Onboarding
        self.coachMarksController.dataSource = self

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Instrumentation: time spent in Review
        Flurry.endTimedEvent("Tab_Review", withParameters: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.coachMarksController.stop(immediately: true)
    }
    
    
    // MARK - Coach marks
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }

    func coachMarksController(_ coachMarksController: CoachMarksController,
                          coachMarkAt index: Int) -> CoachMark {
        return coachMarksController.helper.makeCoachMark(for: self.kolodaView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        coachViews.bodyView.hintLabel.text = "Hello! I'm a Coach Mark!"
        coachViews.bodyView.nextLabel.text = "Ok!"
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
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
        
//        CredentialManager.credentialsProvider.clearCredentials()
//        CredentialManager.credentialsProvider.clearKeychain()
//        AWSSignInManager.sharedInstance().logout { (obj, auth, err) in
//            if((err) != nil) {
//                print(err!)
//            } else {
//                let pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
//                let user = pool.currentUser()
//                user?.forgetDevice()
//                user?.signOut()
//                self.transition()
//            }
//        }
        
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
                self.navigationController!.popToRootViewController(animated: false)
                self.presentSignInViewController()
                let count = self.dataSource.count
                self.dataSource.removeAll()
                self.kolodaView.removeCardInIndexRange(0..<0+count, animated: false)
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
            }
            initData()
        } else {
            // handle cancel operation from user
        }
    }
    
    func initData(){
        noteCardConn.getAllUserWords(forNotecards: true){ (source) in
            self.dataSource = source;
            sourceWords = source;
            let position = self.kolodaView.currentCardIndex
            self.kolodaView.insertCardAtIndexRange(position..<position + self.dataSource.count, animated: true)
            self.bottomSheetVC.getBottomSheetData()
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
            }
            initData()
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
        
        // start coach marks flow
        self.coachMarksController.startOn(self)
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
    
//    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
//        //return Bundle.main.loadNibNamed("NoteCardOverlayView", owner: self, options: nil)?[0] as? OverlayView
//        return nil
//    }
    
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


