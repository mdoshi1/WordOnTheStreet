//
//  NoteCardView.swift
//  
//
//  Created by Max Freundlich on 4/29/17.
//
//

import UIKit

class NoteCardView: UIView {
    
    lazy var wordView: UITextView = {
        let wordView = UITextView(frame:  CGRect(x: 0, y: 0, width: 100, height: 100))
        wordView.backgroundColor = nil;
        return wordView
    }()
    
    lazy var translationView: UITextView = {
        let translationView = UITextView(frame:  CGRect(x: 0, y: 10, width: 100, height: 10))
        translationView.backgroundColor = nil
        return translationView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(wordView)
        backgroundColor = nil;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
