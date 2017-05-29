//
//  PlaceDetailViewController.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 5/4/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import GoogleMaps
import Flurry_iOS_SDK

class PlaceDetailViewController: UIViewController {
    
    enum DetailType: Int {
        case image = 0
        case header
        case words
    }
    
    // MARK: - Properties
    
    private lazy var wordList: UITableView = {
        let wordList = UITableView()
        wordList.delegate = self
        wordList.dataSource = self
        return wordList
    }()
    
    var place: Place?
    var dataSource = [[String: Any]]()
    
    // MARK: - PlaceDetialViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(wordList.usingAutolayout())
        setupConstraints()
        registerReusableCells()
        navigationItem.title = place?.name ?? "Name"
        initData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Instrumentation: time spent in Place Details
        Flurry.logEvent("Place_Details", timed: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Instrumentation: time spent in Place Details
        let flurryParams = ["name": place?.name ?? "Place_Name",
                            "placeId": place?.placeId ?? "Place_Id",
                            "numWords": place?.numWords ?? "Place_Num_Word",
                            "numPeople": place?.numPeople ?? "Place_Num_People",
                            "location": place?.position ?? "Place_Location"
            ] as [String: Any]
        Flurry.endTimedEvent("Place_Details", withParameters: flurryParams)
    }
    
    // MARK: - Helper Methods
    
    private func initData(){
        UserWordManager.shared.pullUserWordIds { (userVocab) in
            UserWordManager.shared.getAllWords(userVocab ?? UserWordManager.shared.userInfo!) { (source) in
                self.dataSource = source
            }
        }
    }
    
    private func setupConstraints() {
        
        // Place TableView
        NSLayoutConstraint.activate([
            wordList.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            wordList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wordList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wordList.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
            ])
    }
    
    private func registerReusableCells() {
        wordList.register(UINib(nibName: Constants.Storyboard.PlaceImageCell, bundle: nil), forCellReuseIdentifier: Constants.Storyboard.PlaceImageCell)
        wordList.register(UINib(nibName: Constants.Storyboard.PlaceHeaderCell, bundle: nil), forCellReuseIdentifier: Constants.Storyboard.PlaceHeaderCell)
        wordList.register(UINib(nibName: Constants.Storyboard.WordCell, bundle: nil), forCellReuseIdentifier: Constants.Storyboard.WordCell)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let navVC = segue.destination as? UINavigationController {
            var dataSource = [[String: String]]()
            if let place = place,
                let vocab = place.vocab {
                for (english,spanish) in vocab.dict {
                    dataSource.append(["english": english, "spanish": spanish])
                }
            }
            let destinationVC = navVC.topViewController as! StandardQuizViewController
            destinationVC.dataSource = dataSource
            destinationVC.navigationItem.title = "Quiz for " + (place?.name ?? "Name")
        }
    }
    
    func toPlaceQuiz(sender: UIButton) {
        
        // Instrumentation: Taking quiz based on location
        let flurryParams = ["name": place?.name ?? "Place_Name",
                            "placeId": place?.placeId ?? "Place_Id",
                            "numWords": place?.numWords ?? "Place_Num_Word",
                            "numPeople": place?.numPeople ?? "Place_Num_People",
                            "location": place?.position ?? "Place_Location"
            ] as [String: Any]
        Flurry.logEvent("Explore_Quiz", withParameters: flurryParams)
        
        performSegue(withIdentifier: Constants.Storyboard.PlaceQuizSegue, sender: nil)
    }
}

// MARK: UITableview Methods

extension PlaceDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch DetailType(rawValue: indexPath.section)! {
        case .image:
            return 0 // TODO: get place images 150.0
        case .header:
            return 95.0
        case .words:
            return 55.0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch DetailType(rawValue: section)! {
        case .image:
            return 1
        case .header:
            return 1
        case .words:
            return place?.numWords ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch DetailType(rawValue: indexPath.section)! {
        case .image:
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "PlaceImageCell", for: indexPath) as! PlaceImageCell
            return imageCell
        case .header:
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "PlaceHeaderCell", for: indexPath) as! PlaceHeaderCell
            headerCell.nameLabel.text = place?.name ?? "Name"
            headerCell.numWordsLabel.text = "\(place?.numWords ?? 0) Words"
            headerCell.numPeopleLabel.text = "\(place?.numPeople ?? 0)"
            headerCell.takeQuizButton.addTarget(self, action: #selector(toPlaceQuiz), for: .touchUpInside)
            headerCell.selectionStyle = UITableViewCellSelectionStyle.none
            return headerCell
        case .words:
            let wordCell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordCell
            if let vocab = place?.vocab {
                let key = Array(vocab.dict.keys)[indexPath.row]
                wordCell.wordLabel.text = key
                wordCell.translationLabel.text = vocab.dict[key]
            } else {
                print("The current place's vocab is nil")
                wordCell.wordLabel.text = "No word available"
                wordCell.translationLabel.text = ""
            }
            for item in self.dataSource {
                if(item["english"] as! String == wordCell.wordLabel.text!){
                    wordCell.addButton.setBackgroundImage(UIImage(named: "check_mark"), for: .normal)
                }
            }
            wordCell.delegate = self
            return wordCell
        }
    }
}

// MARK: - Word Cell Methods

extension PlaceDetailViewController: WordCellDelegate {
    func didSelectWordCell(valueSent: [String:String]) {
        
        // Instrumentation: what word pair did the user add to their own list
        // and other details about the place
        let flurryParams = ["name": place?.name ?? "Place_Name",
                            "placeId": place?.placeId ?? "Place_Id",
                            "numWords": place?.numWords ?? "Place_Num_Word",
                            "numPeople": place?.numPeople ?? "Place_Num_People",
                            "location": place?.position ?? "Place_Location",
                            "sourceWord": valueSent["sourceWord"] ?? "Source_Word",
                            "translationWord": valueSent["translationWord"] ?? "Translation_Word"
            ] as [String: Any]
        
        Flurry.logEvent("Added_Word", withParameters: flurryParams)
        UserWordManager.shared.getWordId(valueSent["sourceWord"]!, spanishWord: valueSent["translationWord"]!) { (wordPairs) in
            UserWordManager.shared.updateUserData(wordPair: wordPairs, data: UserWordManager.shared.userInfo!)
        }
    }
}
