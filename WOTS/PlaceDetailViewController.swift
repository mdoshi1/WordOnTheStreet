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

class PlaceDetailViewController: UIViewController, DidSelectWordAtPlaceProtocol {
    
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
    
    // TODO: remove fake data
    let words = [
        ["english": "drink", "spanish": "la bebida"],
        ["english": "check", "spanish": "el cheque"],
        ["english": "glass", "spanish": "el vaso"],
        ["english": "table", "spanish": "la mesa"],
        ["english": "waiter", "spanish": "el mesero"],
        ["english": "chair", "spanish": "la silla"],
        ["english": "to order", "spanish": "pedir"],
        ["english": "booth", "spanish": "la cabina"],
        ["english": "juice", "spanish": "el jugo"],
        ["english": "fork", "spanish": "el tenedor"],
        ["english": "spoon", "spanish": "la cuchara"],
        ["english": "knife", "spanish": "el cuchillo"],
        ["english": "soup", "spanish": "la sopa"],
        ["english": "dessert", "spanish": "el postre"],
        ["english": "menu", "spanish": "el menú"],
        ["english": "napkin", "spanish": "la servilleta"],
        ["english": "bathroom", "spanish": "el baño"],
        ["english": "to pay", "spanish": "pagar"],
        ["english": "appetizer", "spanish": "la botana"],
        ["english": "water", "spanish": "el agua"]
    ]
    
    
//    let blah = [
//        "drink": "la bebida",
//        "check": "el cheque",
//        "glass": "el vaso",
//        "table": "la mesa",
//        "waiter": "el mesero",
//        "chair": "la silla",
//        "to order": "pedir",
//        "booth": "la cabina",
//        "juice": "el jugo",
//        "fork": "el tenedor",
//        "spoon": "la cuchara",
//        "knife": "el cuchillo",
//        "soup": "la sopa",
//        "dessert": "el postre",
//        "menu": "el menú",
//        "napkin": "la servilleta",
//        "bathroom": "el baño",
//        "to pay": "pagar",
//        "appetizer": "la botana",
//        "water": "el agua"
//    ]
    
    // MARK: - PlaceDetialViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(wordList.usingAutolayout())
        setupConstraints()
        registerReusableCells()
        self.navigationItem.title = place?.name ?? "Name"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Instrumentation: time spent in Place Details
        Flurry.logEvent("Place_Details", timed: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
        wordList.register(UINib(nibName: "PlaceImageCell", bundle: nil), forCellReuseIdentifier: "PlaceImageCell")
        wordList.register(UINib(nibName: "PlaceHeaderCell", bundle: nil), forCellReuseIdentifier: "PlaceHeaderCell")
        wordList.register(UINib(nibName: "WordCell", bundle: nil), forCellReuseIdentifier: "WordCell")
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let navVC = segue.destination as? UINavigationController {
            var dataSource = [[String: String]]()
            for index in 0..<(place?.numWords ?? 10) {
                dataSource.append(words[index])
            }
            let destinationVC = navVC.topViewController as! StandardQuizViewController
            destinationVC.dataSource = dataSource
            destinationVC.navigationItem.title = "Quiz for " + (place?.name ?? "Name")
            
            // Shorten back button title from "Word on the Street" to just "Back"
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
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
        
        performSegue(withIdentifier: "toPlaceQuiz", sender: nil)
    }
}

// MARK: UITableview Methods

extension PlaceDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch DetailType(rawValue: indexPath.section)! {
        case .image:
            return 150.0
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
            return place?.numWords ?? 20
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
                wordCell.wordLabel.text = words[indexPath.row]["english"]
                wordCell.translationLabel.text = words[indexPath.row]["spanish"]
            }

            wordCell.delegate = self
            return wordCell
        }
    }
    
    // MARK: Protocol for WordCell
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
        
    }
    
}
