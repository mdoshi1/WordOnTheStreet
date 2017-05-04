//
//  WordCell.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 5/4/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class WordCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - WordCell

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
