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
    
    var currentWord = WordAttempt()
    var wordIndex = 0;
    override func viewDidLoad() {
        currentWord = WordAttempt(englishWord: dataSource[wordIndex]["english"]!, spanishWord:  dataSource[wordIndex]["spanish"]!)
        currentWordLabel.text = currentWord.spanishWord
        userInput.delegate = self
        doneButton.isHidden = true;
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
        if(userInput.text! == currentWord.englishWord){
            currentWordLabel.textColor = UIColor.black
            wordIndex += 1
            if(wordIndex < dataSource.count){
                currentWord = WordAttempt(englishWord: dataSource[wordIndex]["english"]!, spanishWord:  dataSource[wordIndex]["spanish"]!)
                currentWordLabel.text = currentWord.spanishWord
            } else {
                userInput.isHidden = true;
                currentWordLabel.text = "congrats!"
                currentWordLabel.textColor = UIColor.green
                doneButton.isHidden = false;
            }
        } else {
            currentWordLabel.textColor = UIColor.red
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
