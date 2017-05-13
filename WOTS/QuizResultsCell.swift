//
//  QuizResultsCell.swift
//  WOTS
//
//  Created by Jade Huang on 5/11/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class QuizResultsCell: UITableViewCell {

    @IBOutlet weak var quizResultEnglishLabel: UILabel!
    @IBOutlet weak var quizResultSpanishLabel: UILabel!
    @IBOutlet weak var quizResultImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
