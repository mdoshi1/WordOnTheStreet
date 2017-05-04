//
//  PlaceHeaderCell.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 5/4/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class PlaceHeaderCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numWordsLabel: UILabel!
    @IBOutlet weak var numPeopleLabel: UILabel!
    @IBOutlet weak var peopleImageView: UIImageView!
    @IBOutlet weak var businessTypeLabel: UILabel!
    
    // MARK: PlaceHeaderCell

    override func awakeFromNib() {
        super.awakeFromNib()
        
        peopleImageView.image = UIImage(named: "person")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
