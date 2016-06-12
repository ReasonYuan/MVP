//
//  CheckboxTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-17.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class CheckboxTableViewCell: UITableViewCell {

    
    @IBOutlet weak var checkboxImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
