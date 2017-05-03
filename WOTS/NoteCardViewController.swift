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
    
    var dataSource: [Dictionary<String, String>] = []
    
    fileprivate var isPresentingForFirstTime = true
    let noteCardConn = NoteCardConnection()
    // MARK: Lifecycle
    
    @IBOutlet weak var takeQuizButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        noteCardConn.insertData { () in
            noteCardConn.getWordsForUser { (source) in
                self.dataSource = source;
                sourceWords = source;
                let position = self.kolodaView.currentCardIndex
                self.kolodaView.insertCardAtIndexRange(position..<position + self.dataSource.count, animated: true)
            }
        }
        takeQuizButton.layer.cornerRadius = 4;
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TakeQuizSegue" {
            if let nextVC = segue.destination as? StandardQuizViewController {
                nextVC.dataSource = self.dataSource
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
}

