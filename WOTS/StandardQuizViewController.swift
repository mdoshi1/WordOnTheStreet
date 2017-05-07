//
//  StandardQuizViewController.swift
//  WOTS
//
//  Created by Max Freundlich on 5/2/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class StandardQuizViewController: UIViewController, UITextFieldDelegate {
    var dataSource: [Dictionary<String, String>] = []

    @IBOutlet weak var currentWordLabel: UILabel!
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneUserFeedback: UILabel!
    
    var currentWord = WordAttempt()
    var wordIndex = 0;
    var numIncorrectWords = 0;
    var numMaxAttempts = 3;
    var numAttempts = 0;
    
    override func viewDidLoad() {
        currentWord = WordAttempt(englishWord: dataSource[wordIndex]["english"]!, spanishWord:  dataSource[wordIndex]["spanish"]!)
        currentWordLabel.text = currentWord.spanishWord
        userInput.delegate = self
        doneButton.isHidden = true;
        doneUserFeedback.isHidden = true;
        doneButton.layer.cornerRadius = 4;
        doneButton.addTarget(self, action: #selector(finishQuiz), for: .touchUpInside)
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            }
            
            if(wordIndex < dataSource.count){
                currentWord = WordAttempt(englishWord: dataSource[wordIndex]["english"]!, spanishWord:  dataSource[wordIndex]["spanish"]!)
                currentWordLabel.text = currentWord.spanishWord
                numAttempts = 0
            } else {
                // user finished taking the quiz
                userInput.isHidden = true;
                currentWordLabel.text = "Good job!"
                let score = Float (Float (dataSource.count - numIncorrectWords) / Float(dataSource.count)) * 100
                doneUserFeedback.text = "Score: \(score)%\n" +
                    "Number of incorrect words: \(numIncorrectWords)\n" +
                    "Total number of words tested: \(dataSource.count)"
                currentWordLabel.textColor = UIColor.green
                doneButton.isHidden = false;
                doneUserFeedback.isHidden = false;
            }
        } else {
            currentWordLabel.textColor = UIColor.red
            numAttempts += 1
        }
        
        userInput.text = ""
        //userInput.resignFirstResponder();
        return true;
    }

    
    // MARK: - Navigation
    
    func finishQuiz(sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
