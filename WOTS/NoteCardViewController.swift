//
//  NoteCardViewController.swift
//  Koloda
//
//  Created by Eugene Andreyev on 4/23/15.
//  Copyright (c) 2015 Eugene Andreyev. All rights reserved.
//

import UIKit
import Koloda

private var numberOfCards: Int = 5

class NoteCardViewController: UIViewController {
    
    @IBOutlet weak var kolodaView: CustomNoteCardView!
    @IBOutlet var upGestureRecognizer: UISwipeGestureRecognizer!

    
//    fileprivate var dataSource: [UIImage] = {
//        var array: [UIImage] = []
//        for index in 0..<numberOfCards {
//            array.append(UIImage(named: "Card_like_\(index + 1)")!)
//        }
//        
//        return array
//    }()
    fileprivate var dataSource: [String] = {
        var array: [String] = ["Michael", "Jade", "Max", "Sam"]
        return array
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
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
        let bottomSheetVC = WordListTableViewController()
        
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
        addBottomSheetView()
    }
    
}

// MARK: KolodaViewDelegate

extension NoteCardViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        let position = kolodaView.currentCardIndex
//        for i in 1...4 {
//            dataSource.append(UIImage(named: "Card_like_\(i)")!)
//        }
        dataSource.append("Michael");
        dataSource.append("Jade");
        dataSource.append("Max");
        dataSource.append("Sam");
        kolodaView.insertCardAtIndexRange(position..<position + 4, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
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
        let nc = NoteCardView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        nc.wordView.text = dataSource[Int(index)]
        nc.translationView.text = "Translation of \(dataSource[Int(index)])"
        return nc
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("NoteCardOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
}

