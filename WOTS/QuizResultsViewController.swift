//
//  QuizResultsViewController.swift
//  WOTS
//
//  Created by Jade Huang on 5/11/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class QuizResultsViewController: UIViewController {
    var dataSource: [WordAttempt] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Quiz Results"
        view.addSubview(tableView.usingAutolayout())
        setupConstraints()
        registerReusableCells()
        tableView.tableFooterView = UIView()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissQuizResults as () -> ()))
    }

    func dismissQuizResults() {
        self.dismiss(animated: true, completion: nil)
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
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO:
        let quizResultsCell = tableView.dequeueReusableCell(withIdentifier: "QuizResultsCell", for: indexPath) as! QuizResultsCell
        
        let wordAttempt = dataSource[indexPath.row]
        quizResultsCell.quizResultEnglishLabel.text = wordAttempt.englishWord
        quizResultsCell.quizResultSpanishLabel.text = wordAttempt.spanishWord
        if (wordAttempt.incorrect)! {
            quizResultsCell.quizResultImage.image = UIImage(named: "noOverlayImage")
        } else {
            quizResultsCell.quizResultImage.image = UIImage(named: "yesOverlayImage")
        }
        
        
        return quizResultsCell
    }
    
}

