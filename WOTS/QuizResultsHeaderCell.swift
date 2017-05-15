//
//  QuizResultsHeaderCell.swift
//  WOTS
//
//  Created by Jade Huang on 5/12/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class QuizResultsHeaderCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var congratsLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
