//
//  StandardQuizViewController.swift
//  WOTS
//
//  Created by Max Freundlich on 5/2/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

class StandardQuizViewController: UIViewController, UITextFieldDelegate {
    var dataSource: [Dictionary<String, Any>] = []

    @IBOutlet weak var currentWordLabel: UILabel!
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneUserFeedback: UILabel!
    @IBOutlet weak var numAttemptsLeftLabel: UILabel!
    
    var currentWord = WordAttempt()
    var wordIndex = 0;
    var numIncorrectWords = 0;
    var numMaxAttempts = 2; // technically 3, but 0-indexed
    var numAttempts = 0;
    var allWords = [WordAttempt]();
    
    override func viewDidLoad() {
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named:"chalk-background")!)
        self.view.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)

        currentWord = WordAttempt(englishWord: dataSource[wordIndex]["english"]! as! String, spanishWord:  dataSource[wordIndex]["spanish"]! as! String)
        allWords.append(currentWord)
        
        currentWordLabel.text = currentWord.spanishWord
        userInput.delegate = self
        doneButton.isHidden = true;
        doneUserFeedback.isHidden = true;
        numAttemptsLeftLabel.isHidden = true;
        doneButton.layer.cornerRadius = 6;
        doneButton.addTarget(self, action: #selector(finishQuiz), for: .touchUpInside)
        
        super.viewDidLoad()
        
        // Instrumentation: Time how long user spends in quiz
        Flurry.logEvent("Taking_Quiz", withParameters: nil, timed: true);

        // Do any additional setup after loading the view.
        let backItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickedCancelQuiz(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        // Instrumentation: Stop timer if user cancels quiz
        let flurryParams = ["score": 0.0,
                           "status": "canceled"] as [String : Any]
        Flurry.endTimedEvent("Taking_Quiz", withParameters: flurryParams)
    }
    
    // UITextField Delegates

    func textFieldShouldReturn(_ userInput: UITextField) -> Bool {
        // let user have 3 attempts
        // keep track of how many words the user fails on
        
        if (userInput.text! == currentWord.englishWord || numAttempts == numMaxAttempts) {
            
            currentWordLabel.textColor = UIColor.black
            wordIndex += 1
            
            if (numAttempts == numMaxAttempts) {
                numIncorrectWords += 1
                currentWord.incorrect = true // mark as incorrect
            }
            
            numAttemptsLeftLabel.isHidden = true
            
            if(wordIndex < dataSource.count){
                currentWord = WordAttempt(englishWord: dataSource[wordIndex]["english"]! as! String, spanishWord:  dataSource[wordIndex]["spanish"]! as! String)
                allWords.append(currentWord)
                
                currentWordLabel.text = currentWord.spanishWord
                numAttempts = 0
            } else {
                
                // TODO: push new page/modal with detailed quiz results
                // TODO: make sure to pass the list of WordAttempts, allWords
                // TODO: when done, dismiss, which will dismiss everything
                
                performSegue(withIdentifier: "toQuizResults", sender: nil)

            }
        } else {
            currentWordLabel.textColor = UIColor.red
            numAttempts += 1
            numAttemptsLeftLabel.isHidden = false
            let numAttemptsLeft = (numMaxAttempts + 1) - numAttempts
            numAttemptsLeftLabel.text = "You have \(numAttemptsLeft) attempts left."
        }
        
        userInput.text = ""
        //userInput.resignFirstResponder();
        return true;
    }

    // MARK: - Navigation
    
    func finishQuiz(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let score = Float (Float (dataSource.count - numIncorrectWords) / Float(dataSource.count)) * 100
        
        // Instrumentation: log successful finish of quiz along with scoreInst
        let flurryParams = ["score": score,
                            "status": "finished"] as [String : Any]
        Flurry.endTimedEvent("Taking_Quiz", withParameters: flurryParams)
        
        // prepare data to send:
        let resultsToSend = ["results": allWords,
            "score": score
        ] as [String : Any]
        
        if let navVC = segue.destination as? UINavigationController {
            let destinationVC = navVC.topViewController as! QuizResultsViewController
            destinationVC.dataSource = resultsToSend
//            destinationVC.navigationItem.title = "Quiz for " + (place?.name ?? "Name")
            
            // Shorten back button title from "Word on the Street" to just "Back"
//            let backItem = UIBarButtonItem()
//            backItem.title = ""
//            navigationItem.backBarButtonItem = backItem
        }
    }


}

class WordAttempt: NSObject {
    var englishWord: String?
    var spanishWord: String?
    var incorrect: Bool?
    override init(){
        self.englishWord = ""
        self.spanishWord = ""
        self.incorrect = false;
    }
    init(englishWord: String, spanishWord: String) {
        self.englishWord = englishWord;
        self.spanishWord = spanishWord;
        self.incorrect = false;
    }
}
