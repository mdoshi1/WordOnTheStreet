//
//  ProfileViewController.swift
//  WOTS
//
//  Created by Jade Huang on 5/9/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate {
    
    enum ProfileDetailType: Int {
        case header
        case goalsheader
        case goals
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Word on the Street"
        view.addSubview(tableView.usingAutolayout())
        setupConstraints()
        registerReusableCells()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Helper methods
    
    private func setupConstraints() {
        
        // Place TableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
            ])
    }
    
    private func registerReusableCells() {
        tableView.register(UINib(nibName: "ProfileHeaderCell", bundle: nil), forCellReuseIdentifier: "ProfileHeaderCell")
        tableView.register(UINib(nibName: "GoalHeaderCell", bundle: nil), forCellReuseIdentifier: "GoalHeaderCell")
        tableView.register(UINib(nibName: "GoalsCell", bundle: nil), forCellReuseIdentifier: "GoalsCell")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Image Picker

    // TODO: this doesn't really work
    func loadImagePicker(imagePicker: UIImagePickerController) {
        
        print("Button capture")
        
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .photoLibrary;
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        
        self.dismiss(animated: true, completion: { () -> Void in
        })
        
        // TODO: how to actually set the profile image?
//        profileImage.image = image
    }

}
// MARK: UITableview Methods

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch ProfileDetailType(rawValue: indexPath.section)! {
            case .header:
                return 150.0
            case .goalsheader:
                return 55.0
            case .goals:
                return 55.0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ProfileDetailType(rawValue: section)! {
        case .header:
            return 1
        case .goalsheader:
            return 1
        case .goals:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ProfileDetailType(rawValue: indexPath.section)! {
            case .header:
                let headerCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderCell", for: indexPath) as! ProfileHeaderCell
                
                // TODO: use database/user accounts to fill in name
                headerCell.profileNameLabel.text = "Jade"
                headerCell.profileImageView.image = UIImage(named: "defaultProfileImage")
//                  headerCell.takeQuizButton.addTarget(self, action: #selector(toPlaceQuiz), for: .touchUpInside)
                return headerCell
            
        case .goalsheader:
            
            // TODO: use database/user accounts to fill in goals
            let goalsHeaderCell = tableView.dequeueReusableCell(withIdentifier: "GoalHeaderCell", for: indexPath) as! GoalHeaderCell
            return goalsHeaderCell
            
            case .goals:
                
                // TODO: use database/user accounts to fill in goals
                let goalsCell = tableView.dequeueReusableCell(withIdentifier: "GoalsCell", for: indexPath) as! GoalsCell
                return goalsCell
        }
    }
    
}

