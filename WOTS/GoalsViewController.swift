//
//  GoalsViewController.swift
//  WOTS
//
//  Created by Jade Huang on 5/10/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

class GoalsViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    var isChecked = [Bool]()
    var rowToSelect: IndexPath? = nil
    var selectedGoal: String = ""
    let dailyGoal = "daily_goal"
    let session = SessionManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(tableView.usingAutolayout())
        setupConstraints()
        registerReusableCells()
        tableView.tableFooterView = UIView() // remove empty cells
        tableView.allowsMultipleSelection = false
        
        // TODO: reference backend to see which goal the user has checked
        isChecked = [true, false, false, false]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: refactor after daily goal fix
        var selectedRow = 0;
        switch SessionManager.sharedInstance.userInfo?._wordGoal as! Int{
        case 1:
            selectedRow = 0
            break
        case 3:
            selectedRow = 1
            break
        case 5:
            selectedRow = 2
            break
        case 8:
            selectedRow = 3
            break
        default:
            break
        }
        let selectedIndex = IndexPath(row: selectedRow, section: 0)
        tableView.selectRow(at: selectedIndex, animated: false, scrollPosition: .none)
        tableView.cellForRow(at: selectedIndex)?.accessoryType = .checkmark
        
//        if (self.rowToSelect != nil) {
//            rowToSelect = IndexPath(row: 0, section: 0)
//            self.tableView.selectRow(at: rowToSelect, animated: false, scrollPosition: UITableViewScrollPosition.none)
//            self.tableView.cellForRow(at: rowToSelect!)?.accessoryType = .checkmark
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let selectedIndex = tableView.indexPathForSelectedRow {
            session.userInfo?._wordGoal = Int(goalOptions[selectedIndex.row]["freq"]!) as NSNumber?
            session.setUserWordGoal(goal: Int(goalOptions[selectedIndex.row]["freq"]!)!)
        }
    }
    
    let goalOptions = [
        ["mode": "Casual", "freq": "1"],
        ["mode": "Normal", "freq": "3"],
        ["mode": "Serious", "freq": "5"],
        ["mode": "Expert", "freq": "8"]
    ]
    
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
        tableView.register(UINib(nibName: "GoalOptionCell", bundle: nil), forCellReuseIdentifier: "GoalOptionCell")
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: UITableview Methods

extension GoalsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 55.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return goalOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO: use database/user accounts to fill in goals
        let goalOptionCell = tableView.dequeueReusableCell(withIdentifier: "GoalOptionCell", for: indexPath) as! GoalOptionCell
        goalOptionCell.goalModeLabel.text = goalOptions[indexPath.row]["mode"]!
        goalOptionCell.goalFreqLabel.text = goalOptions[indexPath.row]["freq"]! + " word(s)/day"
//        
//        if (isChecked[indexPath.row]) {
//            goalOptionCell.accessoryType = .checkmark
//        } else {
//            goalOptionCell.accessoryType = .none
//        }
        return goalOptionCell
    }

    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if (isChecked[indexPath.row]) {
//            cell.setSelected(true, animated: false)
//            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? GoalOptionCell{
            cell.accessoryType = .checkmark
            isChecked[indexPath.row] = true
            print ("setting a cell")
            selectedGoal = cell.goalFreqLabel.text!
            
            // Instrumentation: user changed goal
            let flurryParams = ["selectedGoal": selectedGoal]
            Flurry.logEvent("Changed_Goal", withParameters: flurryParams)
            
            self.rowToSelect = indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            isChecked[indexPath.row] = false
        }

    }
    
}
