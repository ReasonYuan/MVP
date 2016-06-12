//
//  SelectFollowUpPatientTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-13.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SelectFollowUpPatientTableViewCell: UITableViewCell {

    @IBOutlet weak var headKuang: UIImageView!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
