//
//  ProfileHeaderCell.swift
//  WOTS
//
//  Created by Jade Huang on 5/10/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileImageEditButton: UIButton!
    weak var delegate: ChangePictureProtocol?

    @IBAction func changeProfileImage(_ sender: Any) {
        let imagePickerVC = UIImagePickerController()

        
        if ((delegate?.responds(to: Selector(("loadNewScreen:")))) != nil)
        {
            delegate?.loadImagePicker(controller: imagePickerVC);
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

protocol ChangePictureProtocol : NSObjectProtocol {
    func loadImagePicker(controller: UIImagePickerController) -> Void;
}
