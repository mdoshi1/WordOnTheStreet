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
        let wordView = UITextView(frame:  CGRect(x: self.frame.width/2 - 100/2, y: 7, width: 100, height: 100))
        wordView.font = .systemFont(ofSize: 24)
        wordView.backgroundColor = nil;
        return wordView
    }()
    
    lazy var translationView: UITextView = {
        let translationView = UITextView(frame:  CGRect(x: self.frame.width/4, y: 50, width: self.frame.width, height: 100))
        translationView.font = .systemFont(ofSize: 20)
        translationView.backgroundColor = nil
        return translationView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let image = UIImageView(image: UIImage(named: "notecard"))
        image.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        addSubview(image)
        addSubview(wordView)
        addSubview(translationView);
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
