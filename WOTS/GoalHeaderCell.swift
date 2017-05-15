//
//  GoalHeaderCell.swift
//  WOTS
//
//  Created by Jade Huang on 5/10/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class GoalHeaderCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var editGoalButton: UIButton!
    @IBOutlet weak var goalLabel: UILabel!
    
    // MARK: - Properties
    
    weak var delegate: GoalCellDelegate?
    
    // MARK: - GoalHeaderCell
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editGoalButton.addTarget(self, action: #selector(editGoal), for: .touchUpInside)
        editGoalButton.layer.cornerRadius = 6;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Button Actions
    
    func editGoal() {
        if let delegate = delegate {
            delegate.editGoal()
        }
    }
}

protocol GoalCellDelegate: class {
    func editGoal()
}
