//
//  QuizResultsViewController.swift
//  WOTS
//
//  Created by Jade Huang on 5/11/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class QuizResultsViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Word on the Street" // TODO: change
        view.addSubview(tableView.usingAutolayout())
        setupConstraints()
        registerReusableCells()
        tableView.tableFooterView = UIView()
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
        tableView.register(UINib(nibName: "QuizResultsCell", bundle: nil), forCellReuseIdentifier: "QuizResultsCell")
//        tableView.register(UINib(nibName: "GoalHeaderCell", bundle: nil), forCellReuseIdentifier: "GoalHeaderCell")
//        tableView.register(UINib(nibName: "GoalsCell", bundle: nil), forCellReuseIdentifier: "GoalsCell")
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

extension QuizResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO: use database/user accounts to fill in goals
        let quizResultsCell = tableView.dequeueReusableCell(withIdentifier: "QuizResultsCell", for: indexPath) as! GoalsCell
        
        // TODO: set the progress for the circles based on database
        quizResultsCell.progressFirstCircle.progress = 0.5 // example
        
        
        // TODO:
        
        
        return quizResultsCell
    }
    
}

