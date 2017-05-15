//
//  ProfileViewController.swift
//  WOTS
//
//  Created by Jade Huang on 5/9/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import AWSCognitoUserPoolsSignIn
import Flurry_iOS_SDK

class ProfileViewController: UIViewController {
    
    enum ProfileDetailType: Int {
        case goal = 0
        case goalProgress
        
        static var count: Int { return ProfileDetailType.goalProgress.hashValue + 1 }
    }
    
    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    fileprivate lazy var tableHeaderView: ProfileHeaderView = {
        let tableHeaderView = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150.0))
        tableHeaderView.delegate = self
        return tableHeaderView
    }()
    
    let imagePicker = UIImagePickerController()
    
    // MARK: - ProfileViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Constants.Storyboard.AppName
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Setup tableview
        tableView.tableHeaderView = tableHeaderView
        view.addSubview(tableView.usingAutolayout())
        setupConstraints()
        registerReusableCells()

        tableView.tableFooterView = UIView()
        
        // Instrumentation: time spent in Profile
        Flurry.logEvent("Tab_Me", timed: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Instrumentation: time spent in Profile
        Flurry.endTimedEvent("Tab_Me", withParameters: nil)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: remove after daily goal fix
        tableView.reloadData()
    }
    
    // implement Protocol function
    func setSelectedCell(valueSent: String) {
        print ("valueSent: \(valueSent)")
        self.selectedGoalCell = valueSent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    private func setupConstraints() {
        
        // Table View
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
            ])
    }
    
    private func registerReusableCells() {
        tableView.register(UINib(nibName: "GoalHeaderCell", bundle: nil), forCellReuseIdentifier: "GoalHeaderCell")
        tableView.register(UINib(nibName: "GoalsCell", bundle: nil), forCellReuseIdentifier: "GoalsCell")
    }
}

// MARK: UITableview Methods

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch ProfileDetailType(rawValue: indexPath.row)! {
        case .goal:
            return 37.0
        case .goalProgress:
            return 66.0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileDetailType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ProfileDetailType(rawValue: indexPath.row)! {
        case .goal:
            
            // TODO: use database/user accounts to fill in goals
            let goalCell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.GoalCell, for: indexPath) as! GoalHeaderCell
            goalCell.delegate = self
            
            // TODO: retrieve from database what the selected goal is
            // TODO: refactor after daily goal fix
            var dailyGoalText = ""
            let selectedRow = UserDefaults.standard.integer(forKey: "daily_goal")
            switch selectedRow {
            case 0:
                dailyGoalText = "1 word/day"
            case 1:
                dailyGoalText = "3 words/day"
            case 2:
                dailyGoalText = "5 words/day"
            case 3:
                dailyGoalText = "8 words/day"
            default:
                break
            }
            goalCell.goalLabel.text = dailyGoalText
            
            return goalCell
            
        case .goalProgress:
            
            // TODO: use database/user accounts to fill in goals
            let goalProgressCell = tableView.dequeueReusableCell(withIdentifier: "GoalsCell", for: indexPath) as! GoalsCell
            
            // TODO: set the progress for the circles based on database
            goalProgressCell.progressFirstCircle.progress = 0.5 // example
            
            return goalProgressCell
        }
    }
}

// MARK: - ProfileHeader Methods

extension ProfileViewController: ProfileHeaderDelegate {
    func changeProfileImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

// MARK: - GoalCell Methods

extension ProfileViewController: GoalCellDelegate {
    func editGoal() {
        performSegue(withIdentifier: "toEditGoal", sender: nil)
    }
}

// MARK: - UIImagePickerController Methods

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // TODO: Send profile image to backend
        if let selectedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            tableHeaderView.setProfileImage(selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
}
