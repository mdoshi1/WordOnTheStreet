//
//  QuizResultsViewController.swift
//  WOTS
//
//  Created by Jade Huang on 5/11/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class QuizResultsViewController: UIViewController {
    var dataSource: [String : Any] = [:]
    
    enum QuizResultsType: Int {
        case header = 0
        case results
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
        self.navigationItem.title = "Quiz Results"
        view.addSubview(tableView.usingAutolayout())
        setupConstraints()
        registerReusableCells()
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissQuizResults as () -> ()))
    }

    func dismissQuizResults() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

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
        tableView.register(UINib(nibName: "QuizResultsHeaderCell", bundle: nil), forCellReuseIdentifier: "QuizResultsHeaderCell")
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
        
        switch QuizResultsType(rawValue: indexPath.section)! {
            case .header:
                return 150.0
            case .results:
                return 100.0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch QuizResultsType(rawValue: section)! {
        case .header:
            return 1
        case .results:
            return (dataSource["results"] as! [WordAttempt]).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        
        switch QuizResultsType(rawValue: indexPath.section)! {
        case .header:
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "QuizResultsHeaderCell", for: indexPath) as! QuizResultsHeaderCell
            
            // stats
            let score = dataSource["score"] as! Float
            // depending on score, change the congrats label
            if (score > 0.9) {
                headerCell.congratsLabel.text = "Very nice!!"
                headerCell.commentLabel.text = "You're a rockstar!"
            } else if (score > 0.7) {
                headerCell.congratsLabel.text = "Good job!"
                headerCell.commentLabel.text = "Not bad, but we can do better"
            } else {
                headerCell.congratsLabel.text = "Nice try!"
                headerCell.commentLabel.text = "Let's review some more :)"
            }
            headerCell.scoreLabel.text = "\(score)%"

            return headerCell
        case .results:
            // TODO:
            let quizResultsCell = tableView.dequeueReusableCell(withIdentifier: "QuizResultsCell", for: indexPath) as! QuizResultsCell
            
            let wordAttempts = dataSource["results"] as! [WordAttempt]
            let wordAttempt = wordAttempts[indexPath.row]
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
    
}


extension NSMutableAttributedString {
    func bold(_ text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 18)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    func normal(_ text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}

