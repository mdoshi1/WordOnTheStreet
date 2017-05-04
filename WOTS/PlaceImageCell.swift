//
//  PlaceImageCell.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 5/4/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class PlaceImageCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var placeImageView: UIImageView!
    
    // MARK: - PlaceImageCell

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
