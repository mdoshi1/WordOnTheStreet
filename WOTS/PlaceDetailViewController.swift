//
//  PlaceDetailViewController.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 5/4/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import GoogleMaps

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
    
    // TODO: remove fake data
    let words = [
        "drink": "la bebida",
        "check": "el cheque",
        "glass": "el vaso",
        "table": "la mesa",
        "waiter": "el mesero",
        "chair": "la silla",
        "to order": "pedir",
        "booth": "la cabina",
        "juice": "el jugo",
        "fork": "el tenedor",
        "spoon": "la cuchara",
        "knife": "el cuchillo",
        "soup": "la sopa",
        "dessert": "el postre",
        "menu": "el menú",
        "napkin": "la servilleta",
        "bathroom": "el baño",
        "to pay": "pagar",
        "appetizer": "la botana",
        "water": "el agua"
    ]
    
    // MARK: - PlaceDetialViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(wordList.usingAutolayout())
        setupConstraints()
        registerReusableCells()
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
            return headerCell
        case .words:
            let wordCell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordCell
            wordCell.wordLabel.text = Array(words.keys)[indexPath.row]
            wordCell.translationLabel.text = Array(words.values)[indexPath.row]
            return wordCell
        }
    }
    
}
