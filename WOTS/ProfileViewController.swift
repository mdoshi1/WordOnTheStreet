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
    let session = SessionManager.sharedInstance
    
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
            var apndStr = " words/day"
            if(session.userInfo?._wordGoal! == 1){
                apndStr = " word/day"
            }
            goalCell.goalLabel.text = String(describing: (session.userInfo?._wordGoal!)!) + apndStr
            return goalCell
            
        case .goalProgress:
            
            let goalProgressCell = tableView.dequeueReusableCell(withIdentifier: "GoalsCell", for: indexPath) as! GoalsCell
            //Get the start of week
            let date = getDateByWeekday(direction: .Previous, "Monday", considerToday: true)
            //For every day of the week, check if the map value exists and update the progress accordingly
            for i in 0 ..< 7 {
                //Progress to next day
                let d = date.addingTimeInterval(TimeInterval(60*60*24*i))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM:dd:YYYY"
                let dateStr = dateFormatter.string(from: d as Date)
                if(session.userInfo?._history != nil){
                    if(session.userInfo?._history?[dateStr] != nil){
                        let learned = (session.userInfo?._history?[dateStr]!)! as! Double
                        let goal = Int((session.userInfo?._wordGoal)!)
                        var percentage = learned/Double(goal)
                        if(percentage > 1.0){
                            percentage = 1.0
                        }
                        switch i {
                        case 0:
                            goalProgressCell.progressFirstCircle.progress = percentage // example
                            break
                        case 1:
                            goalProgressCell.progressSecCircle.progress = percentage
                            break
                        case 2:
                            goalProgressCell.progressThirdCircle.progress = percentage
                            break
                        case 3:
                            goalProgressCell.progressFourthCircle.progress = percentage
                            break
                        case 4:
                            goalProgressCell.progressFifthCircle.progress = percentage
                            break
                        case 5:
                            goalProgressCell.progressSixthCircle.progress = percentage
                            break
                        case 6:
                            goalProgressCell.progressSeventhCircle.progress = percentage
                            break
                        default:
                            break
                        }
                    }
                }
            }
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
            let data = UIImagePNGRepresentation(selectedImage) as NSData?
            let ud = UserData()
            ud.uploadWithData(data: data!, forKey: "profile_pic")
        }
        dismiss(animated: true, completion: nil)
    }
}
