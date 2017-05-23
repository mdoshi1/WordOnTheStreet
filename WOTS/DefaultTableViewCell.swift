//
//  DefaultTableViewCell.swift
//  WOTS
//
//  Created by Jade Huang on 4/30/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class DefaultTableViewCell: UITableViewCell {

    @IBOutlet weak var spanishWordLabel: UILabel!
    @IBOutlet weak var englishWordLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
