//
//  MarkerInfoView.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 5/3/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import GoogleMaps

class MarkerInfoView: UIView {
    
    // MARK: - Properties
    
    private lazy var nameLabel: UILabel = {
        [unowned self] in
        let nameLabel = UILabel()
        nameLabel.text = self.name
        return nameLabel
        }()
    
    private lazy var numWordsLabel: UILabel = {
        [unowned self] in
        let numWordsLabel = UILabel()
        numWordsLabel.text = "\(self.numWords) Words"
        numWordsLabel.font = UIFont.systemFont(ofSize: 12.0)
        return numWordsLabel
        }()
    
    private lazy var numPeopleLabel: UILabel = {
        [unowned self] in
        let numPeopleLabel = UILabel()
        numPeopleLabel.text = String(self.numPeople)
        numPeopleLabel.font = UIFont.systemFont(ofSize: 12.0)
        return numPeopleLabel
        }()
    
    private lazy var personImageView: UIImageView = {
        let personImageView = UIImageView(image: UIImage(named: "person"))
        return personImageView
    }()
    
    private lazy var nextImageView: UIImageView = {
        // Icon made by Freepik from www.flaticon.com
        let nextImageView = UIImageView(image: UIImage(named: "next"))
        return nextImageView
    }()
    
    private let name: String?
    private let numWords: Int
    private let numPeople: Int
    
    private let margins: CGFloat = 5.0
    private let spacing: CGFloat = 10.0
    private let cornerRadius: CGFloat = 5.0
    
    // MARK: - MarkerInfoView
    
    init(frame: CGRect? = nil, forMarker marker: GMSMarker) {
        self.name = marker.title
        self.numWords = Int(arc4random_uniform(20))
        self.numPeople = Int(arc4random_uniform(20))
        
        super.init(frame: frame ?? CGRect.zero)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = cornerRadius
        
        self.addSubview(nameLabel.usingAutolayout())
        self.addSubview(numWordsLabel.usingAutolayout())
        self.addSubview(numPeopleLabel.usingAutolayout())
        self.addSubview(personImageView.usingAutolayout())
        self.addSubview(nextImageView.usingAutolayout())
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Name Label
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margins),
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: margins),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -margins)
            ])
        
        // Number of Words Label
        NSLayoutConstraint.activate([
            numWordsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margins),
            numWordsLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -margins)
            ])
        
        // Number of People Label
        NSLayoutConstraint.activate([
            numPeopleLabel.leadingAnchor.constraint(equalTo: numWordsLabel.trailingAnchor, constant: spacing),
            numPeopleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -margins)
            ])
        
        // Person ImageView
        NSLayoutConstraint.activate([
            personImageView.leadingAnchor.constraint(equalTo: numPeopleLabel.trailingAnchor, constant: 2.0),
            personImageView.centerYAnchor.constraint(equalTo: numPeopleLabel.centerYAnchor),
            personImageView.widthAnchor.constraint(equalToConstant: 12.0),
            personImageView.heightAnchor.constraint(equalTo: personImageView.widthAnchor)
            ])
        
        //Next ImageView
        NSLayoutConstraint.activate([
            nextImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -margins),
            nextImageView.centerYAnchor.constraint(equalTo: numPeopleLabel.centerYAnchor)
            ])
    }
}
