//
//  WordCell.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 5/4/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

class WordCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    var delegate: WordCellDelegate?
    
    // MARK: - WordCell

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addButton.addTarget(self, action: #selector(addToDictionary), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - IBActions
    
    func addToDictionary(sender: UIButton) {
        
        var wordPairDetails = ["sourceWord": self.wordLabel.text!,
                            "translationWord": self.translationLabel.text!
        ]
        self.delegate?.didSelectWordCell(valueSent: wordPairDetails)
        
        sender.setBackgroundImage(UIImage(named: "check_mark"), for: .normal)
        sender.isEnabled = false
    }
}

protocol WordCellDelegate: class {
    func didSelectWordCell(valueSent: [String:String])
}

