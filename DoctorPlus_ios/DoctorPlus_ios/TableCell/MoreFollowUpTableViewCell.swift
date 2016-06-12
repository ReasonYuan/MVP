//
//  MoreFollowUpTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class MoreFollowUpTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followUpTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
