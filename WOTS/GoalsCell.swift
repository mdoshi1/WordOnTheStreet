//
//  GoalsCell.swift
//  WOTS
//
//  Created by Jade Huang on 5/10/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class GoalsCell: UITableViewCell {

    @IBOutlet weak var progressFirstCircle: CircleProgressView!
    @IBOutlet weak var progressSecCircle: CircleProgressView!
    @IBOutlet weak var progressThirdCircle: CircleProgressView!
    @IBOutlet weak var progressFourthCircle: CircleProgressView!
    @IBOutlet weak var progressFifthCircle: CircleProgressView!
    @IBOutlet weak var progressSixthCircle: CircleProgressView!
    @IBOutlet weak var progressSeventhCircle: CircleProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
