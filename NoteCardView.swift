//
//  NoteCardView.swift
//  
//
//  Created by Max Freundlich on 4/29/17.
//
//

import UIKit

class NoteCardView: UIView {
    
    lazy var wordView: UILabel = {
        let wordView = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        wordView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2-20)
        wordView.textAlignment = .center
        wordView.font = .systemFont(ofSize: 40)
        return wordView
    }()
    
    lazy var translationView: UILabel = {
        let translationView = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        translationView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2+20)
        translationView.textAlignment = .center
        translationView.font = .systemFont(ofSize: 30)
        return translationView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let image = UIImageView(image: UIImage(named: "notecard"))
        image.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        addSubview(image)
        addSubview(wordView)
        translationView.isHidden = true;
        addSubview(translationView);
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
