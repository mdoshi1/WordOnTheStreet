//
//  GoalHeaderCell.swift
//  WOTS
//
//  Created by Jade Huang on 5/10/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class GoalHeaderCell: UITableViewCell {
    @IBOutlet weak var dailyGoalLabel: UILabel!

    @IBOutlet weak var editDailyGoalButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
